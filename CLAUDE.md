# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"The Blue Room of SPLORR!!" (repo `tggd-lrj2025`, jam entry LRJ 2025): a turn-based maze crawl drawn on a **64x64 pixel buffer** using 10x10 1-bit sprite tiles. It is deployed at https://thegrumpygamedev.itch.io/tggd-lrj2025 as the VB.NET + Blazor WebAssembly build described below.

**The goal is to rewrite it in Odin compiled to `js_wasm32`.** The VB.NET source in `src/` is the reference implementation (the "original"), the same way the other SPLORR!! ports treated their VB/C#/C++ originals. The author's knowledge base of earlier ports lives in the vault at `/home/yermom/git/bok-of-splorr/splorr` (an additional working directory). Read these before designing the rewrite:

- `Tech/Odin wasm recipe.md` — build command, frame loop, 2D-canvas shim, the shared-framebuffer variant (Murder Hobo, Kordanor's Cabal), pure-logic + native tests variant (Roomba Rights).
- `Gotchas.md` — wasm/Odin pitfalls (never import `core:os` in wasm code, seed the RNG and cap retry loops, read `e.key` before `e.code`, enum-keyed maps and JSON, `ODIN_TEST_THREADS=1`).
- `Tech/Shipping to itch.io.md` — the `shippit.sh` conventions (tests, build, zip, upload only with `--push`; ask before pushing).
- `Games/Murder Hobo of SPLORR!!.md`, `Games/Feretory of SPLORR!!.md`, `Games/Kordanor's Cabal.md` — closest precedents (VB.NET framebuffer/maze games rebuilt in Odin).

Conventions from those ports that apply here: keep the rules in a package with no platform imports so it tests natively; `#+build js` for the page glue, `#+build !js` for tests; decide quirks of the original one at a time with the user rather than "fixing" them silently; the user does the itch.io page text and devlog (`ITCH_DESCRIPTION.md`, `devlog/YYYYMMDD/`).

Toolchain on this machine: `odin` at `/home/yermom/ODIN/odin` (nightly), `dotnet` at `/usr/bin/dotnet`, `butler` for itch.io.

## Commands (Odin port, in `odin/` and `tools/`)

Decisions made with the user: **exact port** (quirks listed and decided one at a time afterwards), **browser only**, **saving to localStorage** (autosave after every turn; a Continue item on the main menu only when a valid save exists; abandon and death clear the save; namespace the key, itch.io HTML5 games share one origin), **shared 64x64 framebuffer** of palette indices that the page expands to a scaled canvas.

```bash
tools/test.sh      # native odin tests (ODIN_TEST_THREADS=1) + web build with -vet-shadowing -vet-unused
tools/build.sh     # web build into build/web (ODIN_FLAGS="-o:size" for the shipping build)
PORT=8091 tools/serve.sh   # serve build/web; avoid 8765, often taken
```

Layout: `odin/game` (package `game`, no platform imports, `core_init`/`core_step`, imported as `tggd:game` via `-collection:tggd=odin`), `odin/platform/web` (`#+build js`: exports + `page/` JS), `odin/tests` (`#+build !js`). Input is the original's 8 `Command`s; the page's key table is a copy of `Home.razor`'s `CommandTable` (case-sensitive and held keys repeat, as in the original; both are quirks to decide later).

Milestone status: 1 (skeleton, smoke screen, build, tests) and 2 (assets) done. Next: static room render, world generation, rules, UI states, saving, touch, ship.

Assets: the original's `Cy*` text fonts and `BlueRoom` sprites (in `Fonts.vb`) have questionable provenance and are **not ported; never regenerate from them**. Replacements are m3x6 (`Font_Id.Small`, HUD) and m5x7 (`.Text`, menus/messages/title, replaces CyFont8x8 too) by Daniel Linssen, and 10x10 sprites cut from the CC0 Bit Bonanza / Bountiful Bits sheets in this repo (floor and threat marker are hand-drawn). `tools/gen/gen_assets.py` (Pillow) generates `odin/game/font_data.odin`; `tools/test.sh` fails if it is stale. Sprite numbers (`Sprite` enum) keep the original's `Chr(n)` values. Fonts are proportional (per-glyph advance), unlike the original's monospace ones, so the original's pixel layouts need rechecking per screen. Credit Daniel Linssen and VEXED in the game. See `odin/assets/README.md`.

## Commands (original VB.NET build, `src/`)

There are no tests and no linter. The solution is `src/src.sln` (net9.0).

```bash
dotnet build src/src.sln                              # VB projects build with TreatWarningsAsErrors + OptionStrict On
dotnet run --project src/TGGDLRJ2025                  # Blazor dev server at http://localhost:5029
bash shippit.sh                                       # publish to ./pub-html and butler push to thegrumpygamedev/tggd-lrj2025:html
```

`shippit.sh` publishes to a public itch.io page and is not executable (run with `bash`). Only run it when the user says to. It pushes `pub-html/wwwroot`, so the channel is `html`.

`src/FontMaker` is a one-off console tool: it reads `source.png` (10x10 cells with 1px gutters, black = off) and writes glyph JSON for `TGGD.UI.FontData`.

## Architecture of the original

Five layers, strictly one-way dependencies, shared generic code in the `TGGD.*` projects:

```
TGGDLRJ2025 (Blazor host: Home.razor, sfx.js)
  -> TGGDLRJ2025.UI        (IUIState state machine, drawing, fonts, palette Hues, Commands)
       -> TGGDLRJ2025.Business  (IWorld/IMap/ILocation/ICharacter/IItem + descriptors, WorldInitializer)
            -> TGGDLRJ2025.Data (plain serializable *Data classes; the entire game state)
  TGGD.UI / TGGD.Business    (generic: IUIBuffer/IUIFont/IUIState, Maze, RNG, Utility)
```

Things that need several files to understand:

- **The world is `WorldData` only.** `World`, `Map`, `Location`, `Character`, `Item` are throwaway wrappers constructed on demand around `(data, playSfx, id)`; they hold no state. Everything references other things by integer index into `WorldData` lists (`MapId`, `LocationId`, `CharacterId`, `ItemId`, `DestinationLocationId` stored as a statistic). `UIContext.World` builds a fresh `World` on every access. A flat-array world with integer ids is the natural Odin shape.
- **Behaviour lives in descriptors, keyed by type-name strings.** `CharacterTypes`, `ItemTypes`, `LocationTypes`, `MapTypes`, `DirectionTypes` each hold a dictionary of `*TypeDescriptor` objects; `"Sword".ToItemTypeDescriptor` dispatches virtual methods (`OnUse`, `OnTake`, `CanSpawn`, `Initialize`, `OnMove`, `OnAttemptUseItemOfType`, ...). Type "enums" are `Module`s of `NameOf` strings. Counts and stats (item/character counts, starting statistics, min/max, durability) are set in each descriptor's constructor, so the descriptors are also the balance table.
- **Generic statistics bag.** Characters, items and locations carry `Dictionary(String, Integer)` statistics plus min/max (`StatisticType`: Health, Satiety, Attack, Defend, SwordDurability, ShieldDurability, RoomNumber, DestinationLocationId). Sword/shield pickup logic copies the item's durability and attack onto the character when the character's own durability is spent; otherwise the item stays as a back-up.
- **World generation (`WorldInitializer`).** Per `MapTypes`: 1 starting room, 14 `Room`s (15x15 each), 1 ending room. `InitializeMainPath` chains rooms start -> ... -> end through a random free direction each, then `InitializeSidePaths` gives every remaining door of every room a random partner room via opposite-direction doors (so the room graph is not a tree). Doors are locations at the midpoint of each wall; a door's destination is `DestinationLocationId`. Then each character and item type is placed `descriptor.*Count` times at a random `CanSpawn` location. Colored doors/locked doors are gated by the seven keys (`SilverKey`..`EmeraldKey`).
- **Messages are modal.** Gameplay pushes `MessageData` (sfx + coloured `Mood` lines) onto `world.Messages`; `Neutral.DetermineState` returns `MessageState` while any are queued, `DeadState` if the avatar is dead, else `NavigationState`. Sfx are queued by name in `UIContext` and drained by the host after every command.
- **UI is a pure state machine.** `IUIState.HandleCommand(command) -> IUIState` returns the next state; `Refresh()` draws into an `IUIBuffer(Of Integer)` of palette indices (24-colour `Palette` list in `Home.razor`). Input is reduced to 8 abstract `Command`s: Up/Down/Left/Right plus Green (space), Blue (enter), Yellow (tab), Red (backspace); WASD/QZ and arrows map to directions in `Home.razor`'s `CommandTable`. There is no real-time loop: one key press = one command = one refresh.
- **Rendering is sprite fonts.** Sprites are "glyphs" of the `BlueRoom` font (10x10 glyph lines serialised in `TGGD.UI`'s `FontData`, produced from the Bit Bonanza / Bountiful Bits sheets at the repo root via `FontMaker`); `CyFont3x5` is the tiny text font for HUD numbers. `*DisplayProperties` map each type to a glyph + `Hue`. The Blazor host paints the 64x64 buffer as an HTML `<table>` of 4096 `<td>` cells, which is the main thing an Odin canvas rewrite replaces.
- **Audio** is 12 `.wav` files in `src/TGGDLRJ2025/wwwroot/sfx/` played through `<audio>` elements by name (`sfx.js`).

## Assets and licensing

`Bit-Bonanza-10x10-v-5.0/` and `Bountiful-Bits-10x10-v-3.1/` are VEXED's CC0 10x10 sprite packs (1-bit variants used); see their README.txt files and the vault's `Tech/Bit Bonanza.md` / `Tech/Bountiful Bits.md` for tile coordinates. `EndingRoomLayout.png` and `IntermediateLayout.png` are the 15x15 room design references; `ss/cover.png` is the itch.io cover.
