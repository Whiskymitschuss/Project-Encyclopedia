#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_data=$(mktemp -d /tmp/timber-tests.XXXXXX)
trap 'rm -rf "$test_data"' EXIT
export XDG_DATA_HOME="$test_data"
test_invocation=0
check() {
 test_invocation=$((test_invocation+1))
 export XDG_DATA_HOME="$test_data/profile-$test_invocation"
 local status=0
 timeout 120s bash scripts/godot.sh --headless "$@" > "$test_data/log" 2>&1 || status=$?
 cat "$test_data/log"
 if [ "$status" -ne 0 ]; then return "$status"; fi
 if rg -q '^(SCRIPT ERROR|ERROR):' "$test_data/log"; then return 1; fi
}
check --editor --import --quit
if [ "$#" -gt 0 ]; then
 for target in "$@"; do
  check --script "res://Tests/$target.gd"
 done
 exit 0
fi
check --script res://Tests/Music2828.gd
check --script res://Tests/Hitches2827.gd
check --script res://Tests/Performance2826.gd
check --script res://Tests/Renderer2825.gd
check --script res://Tests/Daylight2824.gd
check --script res://Tests/Performance2823.gd
check --script res://Tests/Performance2822.gd
check --script res://Tests/Performance2821.gd
check --script res://Tests/Storage2820.gd
check --script res://Tests/ActiveForest2819.gd
check --script res://Tests/Starter2818.gd
check --script res://Tests/Regrowth2817.gd
check --script res://Tests/Design2816.gd
check --script res://Tests/Throughput2815.gd
check --script res://Tests/ForestAccess2813.gd
check --script res://Tests/Timber2812.gd
check --script res://Tests/Performance2811.gd
check --script res://Tests/Logistics2810.gd
check --script res://Tests/Forestry289.gd
check --script res://Tests/Forestry288.gd
check --script res://Tests/Forestry287.gd
check --script res://Tests/FactorySupply286.gd
check --script res://Tests/Supply286.gd
check --script res://Tests/Infrastructure286.gd
check --script res://Tests/WorldRework285.gd
check --script res://Tests/Central284.gd
check --script res://Tests/Forest282.gd
check --script res://Tests/Rollback028.gd
check --script res://Tests/Alpha28.gd
check --script res://Tests/AlphaProgression.gd
check --script res://Tests/Rules.gd
check --script res://Tests/Progression.gd
check --script res://Tests/Scene.gd
check --script res://Tests/WorldTrade27.gd
check --script res://Tests/Placement.gd
check --script res://Tests/Workshop.gd
check --script res://Tests/Companion.gd
check --script res://Tests/WorldLife.gd
check --script res://Tests/Town.gd
check --script res://Tests/Valley.gd
check --script res://Tests/Crafted.gd
check --script res://Tests/Delivery.gd
check --script res://Tests/Construction.gd
check --script res://Tests/LogisticsFix.gd
check --script res://Tests/CityUX.gd
check --script res://Tests/BuildingCard.gd
check --script res://Tests/Journey.gd
check --script res://Tests/Traffic.gd
check --script res://Tests/Fire.gd
check --script res://Tests/FireProtection.gd
check --script res://Tests/Stone.gd
check --script res://Tests/Quality.gd
check --script res://Tests/Presentation26.gd
check --script res://Tests/Startup.gd
check res://Scenes/Main.tscn --quit-after 90
check --script res://Tests/StartupSmoke2826.gd
