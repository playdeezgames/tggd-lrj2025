#!/bin/bash
# Runs every test of the Odin port; exits non-zero on any failure. Usage: tools/test.sh
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
fail=0
step() { echo; echo "== $1"; }

step "generated asset data is up to date"
cp odin/game/font_data.odin build/font_data.odin.before
python3 tools/gen/gen_assets.py >/dev/null
cmp -s odin/game/font_data.odin build/font_data.odin.before && echo "ok" || { echo "FAIL: font_data.odin changed when regenerated; commit the result"; fail=1; }

step "native suite (odin test)"
odin test odin/tests -collection:tggd=odin -vet-shadowing -vet-unused -o:speed -out:build/tests_native -define:ODIN_TEST_THREADS=1 2>&1 | tee build/native_tests.log | grep -E "FAIL|passed|failed|Finished|Error" || true
grep -qE "All tests were successful|successful" build/native_tests.log || fail=1

step "page input rules (node)"
node tools/input_test.js || fail=1

step "web build (vet flags on, so shadowing and unused mistakes show)"
tools/build.sh >/dev/null && echo "ok" || { echo "FAIL: the web build does not compile"; fail=1; }

echo
if [ "$fail" = 0 ]; then echo "ALL TESTS PASSED"; else echo "SOME TESTS FAILED"; exit 1; fi
