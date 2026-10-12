# Assets of the Odin port

The original game's `Cy*` text fonts and `BlueRoom` sprite glyphs (embedded in `src/TGGDLRJ2025.UI/Font/Fonts.vb`) have
questionable provenance and are **not** ported. Replacements:

| Asset | Source | Licence |
| --- | --- | --- |
| `m3x6.ttf` (HUD text) | Daniel Linssen (managore), https://managore.itch.io/m3x6 | free to use with attribution |
| `m5x7.ttf` (menus, messages, title) | Daniel Linssen (managore), https://managore.itch.io/m5x7 | CC0 1.0, attribution appreciated |
| sprites: player, moon person, sword, shield, key, potion, food, door, sign, wall | VEXED (v3x3d): Bit Bonanza 5.0 (`Bit-Bonanza-10x10-v-5.0/`) and Bountiful Bits 3.1 (`Bountiful-Bits-10x10-v-3.1/`), https://v3x3d.itch.io/ | CC0 1.0 |
| sprites: floor, threat marker | drawn for this port in `tools/gen/gen_assets.py` | the project's own |

Licence wording confirmed by the project owner (October 12, 2026): Linssen's fonts are free to use with attribution.
Credit Daniel Linssen and VEXED on the game's page and in the game. `tools/gen/gen_assets.py` turns these into
`odin/game/font_data.odin` and `odin/game/sprite_data.odin`; `tools/test.sh` fails when the committed output is stale.
