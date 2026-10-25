"""Compare real camera work/draw calls using disposable APK assets and profiles.

Desktop llvmpipe timings are not Android FPS. No private player save is used.
"""
from pathlib import Path
import argparse,hashlib,json,os,re,shutil,subprocess,tempfile,time,zipfile
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--baseline-apk',type=Path,default=ROOT/'releases/Timber-Loot-Tycoon-v0.28.20-alpha.1.apk');p.add_argument('--candidate-apk',type=Path);p.add_argument('--output',type=Path,default=ROOT/'docs/alpha1-performance/frames-benchmark.json');args=p.parse_args()
def sha(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def extract(apk,target):
 target.mkdir()
 with zipfile.ZipFile(apk) as z:
  for info in z.infolist():
   if not info.filename.startswith('assets/') or info.is_dir():continue
   f=target/info.filename[7:];f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(z.read(info))
def execute(project,script,output,folder,env):
 current=env.copy();current.update(XDG_DATA_HOME=str(folder/('profile-'+output.stem)),XDG_CONFIG_HOME=str(folder/'config'),XDG_CACHE_HOME=str(folder/'cache'),TIMBER_BENCH_OUTPUT=str(output),TIMBER_PROFILE_FIXTURE=str(ROOT/'Tests/Fixtures/forestry288-company.json'))
 result=subprocess.run(['godot','--path',str(project),'--audio-driver','Dummy','--rendering-method','gl_compatibility','--script',str(ROOT/'Tests'/script)],cwd=project,env=current,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=150)
 if result.returncode or re.search(r'^(SCRIPT ERROR|ERROR):|FAILED:',result.stdout,re.M):raise RuntimeError(result.stdout[-6000:])
 print(output.name,result.stdout[-900:],flush=True)
with tempfile.TemporaryDirectory(prefix='timber-frames2821-',dir='/tmp') as directory:
 folder=Path(directory);baseline=folder/'baseline';extract(args.baseline_apk,baseline)
 candidate=ROOT
 if args.candidate_apk:candidate=folder/'candidate';extract(args.candidate_apk,candidate)
 display=folder/'display';stream=display.open('w')
 server=subprocess.Popen([shutil.which('Xvfb') or '/workspace/.timber-runtime/x11/usr/bin/Xvfb','-displayfd','1','-screen','0','1280x1280x24','-ac','-nolisten','tcp'],stdout=stream,stderr=subprocess.DEVNULL)
 try:
  for _ in range(50):
   if display.read_text().strip():break
   assert server.poll() is None
   time.sleep(.1)
  env=os.environ.copy();env.update(DISPLAY=':'+display.read_text().strip(),LP_NUM_THREADS='4')
  measurements={}
  for name,project in [('before',baseline),('after',candidate)]:
   output=folder/(name+'.json');execute(project,'FrameProfile2821.gd',output,folder,env);measurements[name]=json.loads(output.read_text())
   execute(project,'PaintProfile2821.gd',folder/(name+'.png'),folder,env)
  assert measurements['before']['company_unchanged'] and measurements['after']['company_unchanged']
  assert measurements['before']['company_sha256']==measurements['after']['company_sha256'],'Complete company state changed'
  # Images are independently rendered, never edited or used as replacement assets.
  from PIL import Image,ImageChops,ImageStat
  a=Image.open(folder/'before.png').convert('RGB');b=Image.open(folder/'after.png').convert('RGB');difference=ImageChops.difference(a,b)
  mean=ImageStat.Stat(difference).mean
  assert max(mean)<0.1,(mean,'Paint/architecture changed visually')
  report={'baseline_apk_sha256':sha(args.baseline_apk),'candidate_apk_sha256':sha(args.candidate_apk) if args.candidate_apk else None,'fixture_sha256':sha(ROOT/'Tests/Fixtures/forestry288-company.json'),'method':'Sequential real Main.tscn with generated 18-factory/12-home fixture; 180 seconds simulation then frozen economy, live presentation; 4 camera views x 40 moving-camera frames; median of 3 x 120 forced grid crossings. Same 540x960 resolution, standard quality, adaptive detail off, Mesa llvmpipe/OpenGL. Full company state compared.','before':measurements['before'],'after':measurements['after'],'paint_mean_absolute_rgb_error_0_to_255':mean,'camera_cpu_reduction_percent':100*(1-measurements['after']['cpu_us']['camera_grid_crossing']/measurements['before']['cpu_us']['camera_grid_crossing']),'desktop_only':True,'android_device_tested':False,'temperature_measured':False,'note':'Draw calls and camera CPU are primary evidence. Software-renderer frame time is reported without claiming a phone FPS improvement; world construction may take slightly longer due to one-time paint merging.'}
  args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(report,indent=2)+'\n')
  for name in ['before','after']:shutil.copyfile(folder/(name+'.png'),args.output.parent/('paint-'+name+'.png'))
  print(json.dumps(report,indent=2))
 finally:
  server.terminate();server.wait(timeout=10);stream.close()
