#!/bin/bash
# Builds the Odin port's web page into build/web (git-ignored). Extra odin flags: ODIN_FLAGS="-o:size" tools/build.sh
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/web
odin build odin/platform/web -target:js_wasm32 -out:build/web/platform.wasm -collection:tggd=odin -vet-shadowing -vet-unused ${ODIN_FLAGS:-}
cp odin/platform/web/page/index.html odin/platform/web/page/platform.js odin/platform/web/page/storage.js build/web/
cp "$(odin root)/core/sys/wasm/js/odin.js" build/web/
echo "web build: build/web (serve with tools/serve.sh)"
