"""Compare the shipped 0.28.1 routing with only the route-cache optimization.

Uses APK assets, generated fixtures and disposable profiles. Does not read player data.
The derived cache-only case deliberately excludes later scheduling/gameplay changes.
"""
from pathlib import Path
import hashlib,json,os,shutil,subprocess,tempfile,zipfile
root=Path(__file__).resolve().parents[1]
base_commit='e1f70e76a30522f8456762c50f57ac580dfd311f'
apk=root/'releases/Timber-Loot-Tycoon-v0.28.1-alpha.1.apk'
fixture=root/'Tests/Fixtures/rollback028-from029.json'
with tempfile.TemporaryDirectory(prefix='timber-route-benchmark-',dir='/tmp') as folder:
    temp=Path(folder);baseline=temp/'baseline';baseline.mkdir()
    with zipfile.ZipFile(apk) as z:
        for item in z.infolist():
            if not item.filename.startswith('assets/') or item.is_dir(): continue
            target=baseline/item.filename[7:];target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(z.read(item))
    cached=temp/'cached';shutil.copytree(baseline,cached)
    game=subprocess.check_output(['git','show',base_commit+':Managers/Game.gd'],cwd=root,text=True)
    current=(root/'Managers/Game.gd').read_text()
    begin=current.index('func delivery_routes()');end=current.index('func start_delivery()',begin)
    start=game.index('func delivery_routes()');finish=game.index('func start_delivery()',start)
    game=game[:start]+current[begin:end]+game[finish:]
    for name in ['Economy/TownRules.gd','Economy/LogisticsRoutes.gd','Managers/Game.gd']:
        path=cached/name;path.with_suffix('.gd.remap').unlink(missing_ok=True)
        source=game if name=='Managers/Game.gd' else (root/name).read_text()
        if name=='Economy/LogisticsRoutes.gd':
            # Compare caching alone, even after later releases change loading docks.
            original=subprocess.check_output(['git','show',base_commit+':'+name],cwd=root,text=True)
            old_begin=original.index('static func road_to_point(')
            old_end=original.index('static func encode(',old_begin)
            old_body=original[old_begin:old_end]
            old_body=old_body[old_body.index(' var cells ='):]
            begin=source.index('static func calculate(')
            end=source.index('static func encode(',begin)
            header=source[begin:source.index('\n',begin)+1]
            source=source[:begin]+header+old_body+source[end:]
        path.write_text(source)
    results={}
    for name,project in [('baseline',baseline),('cached',cached)]:
        output=temp/(name+'.json')
        script=temp/(name+'.gd')
        script.write_text('''extends SceneTree
func _initialize(): call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(%s)))
 var began=Time.get_ticks_msec()
 game.simulate(1800)
 var milliseconds=Time.get_ticks_msec()-began
 var state=game.snapshot()
 state.erase("last_seen")
 var file=FileAccess.open(%s,FileAccess.WRITE)
 file.store_string(JSON.stringify({"milliseconds":milliseconds,"state":state},"",true,true))
 print("ROUTE BENCHMARK: ",milliseconds," ms")
 quit()
''' % (json.dumps(str(fixture)),json.dumps(str(output))))
        env=os.environ.copy();env['XDG_DATA_HOME']=str(temp/('profile-'+name))
        run=subprocess.run(['godot','--headless','--path',str(project),'--script',str(script)],env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120)
        if run.returncode or 'SCRIPT ERROR:' in run.stdout or '\nERROR:' in run.stdout: raise RuntimeError(run.stdout)
        results[name]=json.loads(output.read_text())
        print(name,results[name]['milliseconds'],'ms',flush=True)
    assert results['baseline']['state']==results['cached']['state'],'Routing optimization changed simulation state'
    state_hash=hashlib.sha256(json.dumps(results['baseline']['state'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
    report={'seconds_simulated':1800,'baseline_apk_sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),'baseline_source_commit':base_commit,'fixture_sha256':hashlib.sha256(fixture.read_bytes()).hexdigest(),'baseline_ms':results['baseline']['milliseconds'],'cached_ms':results['cached']['milliseconds'],'speedup':results['baseline']['milliseconds']/max(1,results['cached']['milliseconds']),'identical_complete_state_excluding_last_seen':True,'result_state_sha256':state_hash,'scope':'Cache-only derived APK assets; no 0.28.2 freight or UI changes in this comparison','desktop_only':True,'android_device_tested':False}
    target=root/'docs/alpha1-forest/route-benchmark.json';target.parent.mkdir(parents=True,exist_ok=True);target.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
