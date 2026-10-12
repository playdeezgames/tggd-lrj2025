#!/bin/bash
# Prepares the itch.io build: tests, an optimised web build, a zip. Pushes ONLY with --push. Never commits or deletes anything.
# Usage: tools/ship.sh [--push]
set -euo pipefail
cd "$(dirname "$0")/.."
TARGET="thegrumpygamedev/tggd-lrj2025:html"
ZIP="build/tggd-lrj2025-html5.zip"

tools/test.sh
ODIN_FLAGS="-o:size" tools/build.sh
rm -f "$ZIP"
(cd build/web && zip -q -9 -r "../tggd-lrj2025-html5.zip" .)
echo "zip: $ZIP ($(du -h "$ZIP" | cut -f1)); wasm $(du -h build/web/platform.wasm | cut -f1)"
unzip -l "$ZIP" | tail -20

if [ "${1:-}" = "--push" ]; then
	if [ -n "$(git status --porcelain)" ]; then echo "note: the working tree has uncommitted changes; what is pushed is the working tree, not a commit"; fi
	butler push "$ZIP" "$TARGET"
	echo "pushed to $TARGET. It goes live after itch.io processes it; check: butler status $TARGET"
else
	echo "not pushed (run tools/ship.sh --push when you want it live; the target is $TARGET)"
fi
