"""Rebuild or verify reusable visual resources in an isolated Godot profile."""
from pathlib import Path
import argparse,hashlib,json,os,re,subprocess,tempfile
ROOT=Path(__file__).resolve().parents[1];BAKED=ROOT/'Assets/Baked';MANIFEST=BAKED/'manifest.json'

def sha(path):
 with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def sources():
 paths=set()
 for directory in ['Buildings','art','characters/beavers','Vehicles']:
  paths.update((ROOT/directory).glob('*.gd'))
 paths.update(ROOT/x for x in ['Components/ValleyLandscape.gd','Components/SceneryBlueprint.gd','Components/ProductionMachine.gd','Components/YardHandling.gd','Components/ProductionCampus.gd','Economy/Catalog.gd','scripts/bake_runtime.gd','scripts/MeshLodBake.gd','scripts/bake_runtime.py'])
 return {str(p.relative_to(ROOT)):sha(p) for p in sorted(paths)}
def assets():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(BAKED.iterdir()) if p.suffix in ['.scn','.res']}
def verify():
 data=json.loads(MANIFEST.read_text())
 assert data['sources']==sources(),'Visual source changed: rebuild with python3 scripts/bake_runtime.py before exporting.'
 assert data['assets']==assets(),'Prepared resource set changed, is incomplete, or has stale files.'
 assert data['resource_count']==len(data['assets']) and data['resource_count']>=690
 print('VERIFIED BAKED RESOURCES:',data['resource_count'],flush=True)
p=argparse.ArgumentParser();p.add_argument('--verify-only',action='store_true');args=p.parse_args()
if not args.verify_only:
 with tempfile.TemporaryDirectory(prefix='timber-bake-profile-',dir='/tmp') as profile:
  env=os.environ.copy();env['XDG_DATA_HOME']=profile
  for command in [['--editor','--import','--quit'],['--script','res://scripts/bake_runtime.gd']]:
   result=subprocess.run(['bash',str(ROOT/'scripts/godot.sh'),'--headless',*command],cwd=ROOT,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=240)
   if result.returncode or re.search(r'^(SCRIPT ERROR|ERROR):',result.stdout,re.M):raise RuntimeError(result.stdout[-6000:])
   print(result.stdout[-700:],flush=True)
 data={'sources':sources(),'assets':assets(),'generator':'Godot 4.6.3 offline geometry/resource build; disposable profile; runtime scene-tree APIs stay on the main thread.'}
 data['resource_count']=len(data['assets']);MANIFEST.write_text(json.dumps(data,indent=2)+'\n')
verify()
