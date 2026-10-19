#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_data=$(mktemp -d /tmp/timber-tests.XXXXXX)
trap 'rm -rf "$test_data"' EXIT
export XDG_DATA_HOME="$test_data"
check() {
 local status=0
 timeout 120s bash scripts/godot.sh --headless "$@" > "$test_data/log" 2>&1 || status=$?
 cat "$test_data/log"
 if [ "$status" -ne 0 ]; then return "$status"; fi
 if rg -q '^(SCRIPT ERROR|ERROR):' "$test_data/log"; then return 1; fi
}
check --editor --import --quit
check --script res://Tests/Rules.gd
check --script res://Tests/Progression.gd
check --script res://Tests/Scene.gd
check --script res://Tests/Placement.gd
check --script res://Tests/Workshop.gd
check --script res://Tests/Companion.gd
check --script res://Tests/WorldLife.gd
check --quit-after 90
