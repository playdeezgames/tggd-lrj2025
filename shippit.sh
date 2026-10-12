#!/bin/bash
# Builds, tests and zips the Odin build; uploads to itch.io only with --push. See tools/ship.sh.
exec "$(dirname "$0")/tools/ship.sh" "$@"
