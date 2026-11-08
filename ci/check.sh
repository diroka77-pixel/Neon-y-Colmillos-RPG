#!/usr/bin/env bash
set -euo pipefail
engine="${1:?Path to Godot 4.3 required}"
mkdir -p build
"$engine" --headless --path . --editor --quit 2>&1 | tee build/import.log
! grep -E 'SCRIPT ERROR|Parse Error|ERROR:' build/import.log
"$engine" --headless --path . --script res://tests/run_tests.gd 2>&1 | tee build/tests.log
! grep -E 'SCRIPT ERROR|Parse Error|ERROR:|FAIL:' build/tests.log
"$engine" --headless --path . --quit-after 180 2>&1 | tee build/smoke.log
! grep -E 'SCRIPT ERROR|Parse Error|ERROR:' build/smoke.log
