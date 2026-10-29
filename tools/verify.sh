#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

python3 -m unittest discover -s "$ROOT/tests" -p 'test_*.py' -v
"$GODOT_BIN" --headless --path "$ROOT" --import --quit
"$GODOT_BIN" --headless --path "$ROOT" --script res://tests/smoke_runner.gd

echo 'STEP0_VERIFICATION_OK'
