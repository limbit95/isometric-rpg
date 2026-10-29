#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

# Godot may log an engine ERROR but still exit with status 0.
# Reject these cases rather than reporting a false-green runtime smoke.
run_godot_checked() {
    local output
    output="$(mktemp)"
    if ! "$GODOT_BIN" --headless --path "$ROOT" "$@" 2>&1 | tee "$output"; then
        rm -f "$output"
        return 1
    fi
    if grep -q 'ERROR:' "$output"; then
        echo 'Godot logged an engine ERROR; failing verification.' >&2
        rm -f "$output"
        return 1
    fi
    rm -f "$output"
}

python3 -m unittest discover -s "$ROOT/tests" -p 'test_*.py' -v
run_godot_checked --import --quit
run_godot_checked --script res://tests/smoke_runner.gd
run_godot_checked --script res://tests/combat_smoke_runner.gd
run_godot_checked --script res://tests/enemy_ai_smoke_runner.gd
run_godot_checked --script res://tests/skills_smoke_runner.gd
run_godot_checked --script res://tests/progression_inventory_smoke_runner.gd

echo 'STEP4_VERIFICATION_OK'
