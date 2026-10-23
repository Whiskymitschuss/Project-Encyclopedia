"""Seed only a temporary automated profile, never an installed player profile."""
from pathlib import Path
import json,sys,time
profile=Path(sys.argv[1]).resolve()
if not profile.is_relative_to('/tmp'):
    raise SystemExit('Cold-start fixtures require a temporary /tmp test profile.')
root=Path(__file__).resolve().parents[1]
fixture=sys.argv[2] if len(sys.argv)>2 else 'rollback028-from029'
if fixture not in {'rollback028-from029','forestry288-company'}:
    raise SystemExit('Unknown generated cold-start fixture.')
data=json.loads((root/('Tests/Fixtures/'+fixture+'.json')).read_text())
data['last_seen']=time.time()-28800
target=profile/'TimberLootReborn/timber_rebuild.json'
target.parent.mkdir(parents=True,exist_ok=True)
target.write_text(json.dumps(data))
