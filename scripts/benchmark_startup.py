"""Reproduce the pure startup optimization comparison in isolated temporary projects.

The fixture patch deliberately excludes new scheduling behavior so complete states
can be compared exactly. No private profile is read, modified or copied.
"""
from pathlib import Path
import hashlib, io, json, os, re, subprocess, tempfile, zipfile
ROOT=Path(__file__).resolve().parents[1]
BASELINE='248ac96030956bcb6584fcd75e3e861addf69e0e'
PATCH=ROOT/'Tests/Fixtures/startup288-optimization.patch'
def run(args, env, cwd, timeout=180):
    result=subprocess.run(args,env=env,cwd=cwd,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=timeout)
    if result.returncode or re.search(r'^(SCRIPT ERROR|ERROR):',result.stdout,re.M):
        raise RuntimeError(result.stdout[-6000:])
    return result.stdout
with tempfile.TemporaryDirectory(prefix='timber-startup-benchmark-',dir='/tmp') as folder:
    temp=Path(folder)
    files=[n for n in subprocess.check_output(['git','ls-tree','-r','--name-only','-z',BASELINE],cwd=ROOT).decode().split('\0') if n and not n.startswith('releases/')]
    archive=subprocess.check_output(['git','archive','--format=zip',BASELINE,'--',*files],cwd=ROOT)
    projects={}
    for name in ['before','optimized']:
        project=temp/name;project.mkdir()
        with zipfile.ZipFile(io.BytesIO(archive)) as z:z.extractall(project)
        if name=='optimized':subprocess.run(['git','apply',str(PATCH)],cwd=project,check=True)
        env=os.environ.copy()
        env.update(XDG_DATA_HOME=str(temp/('import-'+name)),XDG_CONFIG_HOME=str(temp/'config'),XDG_CACHE_HOME=str(temp/'cache'))
        run(['godot','--headless','--editor','--import','--quit'],env,project)
        projects[name]=project
    results={}
    for fixture in ['rollback028-from029','forestry288-company']:
        cases={}
        for name,project in projects.items():
            output=temp/(fixture+'-'+name+'.json')
            script=temp/'measure.gd'
            script.write_text('''extends SceneTree
func _initialize(): call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(%s)))
 var began=Time.get_ticks_msec()
 game.simulate(28800)
 var milliseconds=Time.get_ticks_msec()-began
 var state=game.state.duplicate(true)
 state.erase("last_seen")
 FileAccess.open(%s,FileAccess.WRITE).store_string(JSON.stringify({"milliseconds":milliseconds,"state":state},"",true,true))
 quit()
'''%(json.dumps(str(ROOT/'Tests/Fixtures'/(fixture+'.json'))),json.dumps(str(output))))
            env=os.environ.copy()
            env.update(XDG_DATA_HOME=str(temp/('profile-'+fixture+'-'+name)),XDG_CONFIG_HOME=str(temp/'config'),XDG_CACHE_HOME=str(temp/'cache'))
            run(['godot','--headless','--script',str(script)],env,project)
            cases[name]=json.loads(output.read_text())
            print(fixture,name,cases[name]['milliseconds'],'ms',flush=True)
        assert cases['before']['state']==cases['optimized']['state'],fixture+' full state changed'
        results[fixture]={'before_ms':cases['before']['milliseconds'],'optimized_ms':cases['optimized']['milliseconds'],'complete_state_identical':True,'state_sha256':hashlib.sha256(json.dumps(cases['before']['state'],sort_keys=True,separators=(',',':')).encode()).hexdigest(),'fixture_sha256':hashlib.sha256((ROOT/'Tests/Fixtures'/(fixture+'.json')).read_bytes()).hexdigest()}
    report={'baseline_commit':BASELINE,'seconds_simulated':28800,'scope':'Pure optimization patch; priority/fairness/order fixes excluded from the identical-state comparison','patch_sha256':hashlib.sha256(PATCH.read_bytes()).hexdigest(),'fixtures':results,'desktop_only':True,'android_device_tested':False,'fixture_origin':'Generated test companies, no private player save'}
    target=ROOT/'docs/alpha1-recovery/startup-benchmark.json'
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
