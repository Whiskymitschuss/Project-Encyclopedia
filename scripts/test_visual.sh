#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_data=$(mktemp -d /tmp/timber-visual.XXXXXX)
server_pid=""
cleanup() {
 if [ -n "$server_pid" ]; then kill "$server_pid" 2>/dev/null || true; fi
 rm -rf "$test_data"
}
trap cleanup EXIT
export XDG_DATA_HOME="$test_data/profile"
export LP_NUM_THREADS="${LP_NUM_THREADS:-4}"
if [ -z "${DISPLAY:-}" ]; then
 server=$(command -v Xvfb || true)
 if [ -z "$server" ]; then server=/workspace/.timber-runtime/x11/usr/bin/Xvfb; fi
 if [ ! -x "$server" ]; then echo 'Xvfb or an existing graphical DISPLAY is required.' >&2; exit 1; fi
 "$server" -displayfd 3 -screen 0 1280x1280x24 -ac -nolisten tcp 3>"$test_data/display" >"$test_data/x11.log" 2>&1 &
 server_pid=$!
 for attempt in {1..50}; do
  if [ -s "$test_data/display" ]; then break; fi
  if ! kill -0 "$server_pid" 2>/dev/null; then cat "$test_data/x11.log"; exit 1; fi
  sleep 0.1
 done
 if [ ! -s "$test_data/display" ]; then cat "$test_data/x11.log"; exit 1; fi
 export DISPLAY=":$(cat "$test_data/display")"
fi
targets=(VisualMusic2828 VisualHitches2827 VisualPerformance2826 VisualRenderer2825 VisualDaylight2824 VisualPerformance2823 VisualPerformance2822 VisualPerformance2821 VisualStorage2820 VisualActiveForest2819 VisualStarter2818 VisualRegrowth2817 VisualDesign2816 VisualThroughput2815 VisualLoading2814 VisualForestAccess2813 VisualTimber2812 VisualPerformance2811 VisualLogistics2810 VisualForestry289 VisualForestry288 VisualForestry287 VisualFactorySupply286 VisualSupply286 VisualBeavers285 VisualMap2842 VisualFactory284 VisualCampus283 VisualColdStart288 VisualColdStart282 VisualForest282 VisualRollback028 VisualUI VisualStartup VisualBuildingCard VisualCityUX VisualFireUI VisualFireProtection VisualCrafted VisualQuality VisualPresentation26 VisualWorldTrade27 VisualAlpha28)
if [ "$#" -gt 0 ]; then targets=("$@"); fi
for target in "${targets[@]}"; do
 export XDG_DATA_HOME="$test_data/profile-$target"
 if [ "$target" = VisualColdStart288 ]; then python3 scripts/seed_cold.py "$XDG_DATA_HOME" forestry288-company; fi
 if [ "$target" = VisualColdStart282 ]; then python3 scripts/seed_cold.py "$XDG_DATA_HOME"; fi
 status=0
 timeout 120s bash scripts/godot.sh --audio-driver Dummy --rendering-method "${TIMBER_RENDERER:-gl_compatibility}" --script "res://Tests/$target.gd" >"$test_data/log" 2>&1 || status=$?
 cat "$test_data/log"
 if [ "$status" -ne 0 ]; then exit "$status"; fi
 if rg -q '^(SCRIPT ERROR|ERROR):' "$test_data/log"; then exit 1; fi
done
