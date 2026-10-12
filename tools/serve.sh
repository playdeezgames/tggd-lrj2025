#!/bin/bash
# Serves build/web on http://localhost:8080 (override with PORT=...). The wasm must come over http, not file://.
cd "$(dirname "$0")/../build/web" && exec python3 -m http.server "${PORT:-8080}"
