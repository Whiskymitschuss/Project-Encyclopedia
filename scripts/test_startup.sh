#!/usr/bin/env bash
# A separate process is essential: this verifies the real Game autoload, not
# only calling the catch-up API after an already successful fresh launch.
set -euo pipefail
cd "$(dirname "$0")/.."
test_data=$(mktemp -d /tmp/timber-cold-start.XXXXXX)
trap 'rm -rf "$test_data"' EXIT
export XDG_DATA_HOME="$test_data/profile"
python3 - "$XDG_DATA_HOME" <<'PY'
from pathlib import Path
import json,sys,time
path=Path(sys.argv[1])/'TimberLootReborn/timber_rebuild.json'
path.parent.mkdir(parents=True,exist_ok=True)
path.write_text(json.dumps({'schema':1,'last_seen':time.time()-40000,'elapsed':1234.0,
 'tutorial':5,'coins':12345.0,'city_services':{'enabled':False},'workers':4,'resources':{'wood':80.0}}))
PY
status=0
timeout 120s bash scripts/godot.sh --headless --script res://Tests/ColdStart291.gd > "$test_data/log" 2>&1 || status=$?
cat "$test_data/log"
if [ "$status" -ne 0 ]; then exit "$status"; fi
if rg -q '^(SCRIPT ERROR|ERROR):' "$test_data/log"; then exit 1; fi
