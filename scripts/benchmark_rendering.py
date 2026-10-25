"""Measure real Main render attribution sequentially; never use a player save."""
from pathlib import Path
import argparse,json,os,re,shutil,subprocess,tempfile,time
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--baseline',type=Path,required=True);p.add_argument('--candidate',type=Path,default=ROOT);p.add_argument('--renderer',choices=['gl_compatibility','mobile'],default='gl_compatibility');p.add_argument('--output',type=Path,required=True);args=p.parse_args()
with tempfile.TemporaryDirectory(prefix='timber-render2826-',dir='/tmp') as name:
 folder=Path(name);display=folder/'display'
 with display.open('w') as stream:
  server=subprocess.Popen([shutil.which('Xvfb') or '/workspace/.timber-runtime/x11/usr/bin/Xvfb','-displayfd','1','-screen','0','1280x2560x24','-ac','-nolisten','tcp'],stdout=stream,stderr=subprocess.DEVNULL)
  try:
   for _ in range(50):
    if display.read_text().strip():break
    assert server.poll() is None
    time.sleep(.1)
   env=os.environ.copy();env.update(DISPLAY=':'+display.read_text().strip(),LP_NUM_THREADS='4',TIMBER_PROFILE_FIXTURE=str(ROOT/'Tests/Fixtures/forestry288-company.json'))
   if args.renderer=='mobile':
    driver=Path('/workspace/.timber-runtime/vulkan')
    env['VK_DRIVER_FILES']=str(driver/'usr/share/vulkan/icd.d/lvp_icd.json');env['LD_LIBRARY_PATH']=str(driver/'usr/lib/x86_64-linux-gnu')+(':'+env['LD_LIBRARY_PATH'] if env.get('LD_LIBRARY_PATH') else '')
   results={}
   for tag,project in [('before',args.baseline),('after',args.candidate)]:
    output=folder/(tag+'.json');current=env.copy();current.update(XDG_DATA_HOME=str(folder/tag),XDG_CONFIG_HOME=str(folder/'config'),XDG_CACHE_HOME=str(folder/'cache'),TIMBER_BENCH_OUTPUT=str(output))
    r=subprocess.run(['godot','--path',str(project.resolve()),'--audio-driver','Dummy','--rendering-method',args.renderer,'--script',str(ROOT/'Tests/RenderProfile2826.gd')],env=current,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.with_name(args.output.stem+'-'+tag+'.log').write_text(r.stdout)
    if r.returncode or re.search(r'^(SCRIPT ERROR|ERROR):|FAILED:',r.stdout,re.M):raise RuntimeError(r.stdout[-5000:])
    results[tag]=json.loads(output.read_text());assert results[tag]['company_unchanged'];assert results[tag]['renderer']==args.renderer
    print(tag,json.dumps(results[tag]),flush=True)
   assert results['before']['company_sha256']==results['after']['company_sha256']
   results['method']='Same generated 18-factory/12-home company, 180 simulated seconds then frozen economy/presentation, 1080x2340, fixed daylight, synthetic tier-3 relief, sequential cases with 12 warmup and 30 measured frames. Root-viewport CPU/GPU timestamp medians; desktop software rendering. No phone FPS claim.'
   results['android_device_tested']=False;args.output.write_text(json.dumps(results,indent=2)+'\n')
  finally:server.terminate();server.wait(timeout=10)
