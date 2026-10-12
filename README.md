# The Blue Room of SPLORR!!

A 64 by 64 pixel maze crawl for the Low-Rez Jam 2025 by TheGrumpyGameDev: https://thegrumpygamedev.itch.io/tggd-lrj2025

The game is rebuilt in Odin and WebAssembly in `odin/`. The original VB.NET and Blazor version is kept in `src/` as the
reference.

```bash
tools/test.sh               # tests and a web build
tools/build.sh              # web build into build/web
PORT=8080 tools/serve.sh    # serve build/web
tools/ship.sh [--push]      # tests, optimised build, zip; uploads to itch.io only with --push
```

Credits: fonts m3x6 and m5x7 by Daniel Linssen; sprites from Bit Bonanza and Bountiful Bits by VEXED (CC0); sound
effects by TheGrumpyGameDev. See `odin/assets/README.md` and `QUIRKS.md` (changes from the original).
