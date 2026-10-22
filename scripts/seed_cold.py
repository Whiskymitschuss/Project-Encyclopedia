"""Seed only a temporary automated profile, never an installed player profile."""
from pathlib import Path
import json,sys,time
profile=Path(sys.argv[1]).resolve()
if not profile.is_relative_to('/tmp'):
    raise SystemExit('Cold-start fixtures require a temporary /tmp test profile.')
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'Tests/Fixtures/rollback028-from029.json').read_text())
data['last_seen']=time.time()-28800
target=profile/'TimberLootReborn/timber_rebuild.json'
target.parent.mkdir(parents=True,exist_ok=True)
target.write_text(json.dumps(data))
