# TODO

## Attribution for assets used (required before shipping)

The Odin port uses third-party assets that require or request credit. Show it **in the game** (a credits/About screen
reachable from the title or main menu, or a line on the title screen) **and on the itch.io page** (`ITCH_DESCRIPTION.md`).

- [x] (credits screen, ITCH_DESCRIPTION.md) **m3x6 and m5x7 fonts**, by Daniel Linssen (managore): https://managore.itch.io/m3x6, https://managore.itch.io/m5x7. m3x6 is free to use *with attribution* (confirmed by the project owner); m5x7 is CC0, attribution appreciated.
- [x] (credits screen, ITCH_DESCRIPTION.md) **Bit Bonanza 5.0 and Bountiful Bits 3.1**, by VEXED (v3x3d), CC0 (credit appreciated, not required): https://v3x3d.itch.io/. Sprites used: player, moon person, sword, shield, key, potion, food, door, sign, wall.
- [x] Sound effects (`odin/platform/web/page/sfx/*.wav`): made by the project owner (confirmed October 12, 2026); credited as such.
- [x] Credits are in the game (main menu, Credits) and in `ITCH_DESCRIPTION.md`. Keep `odin/assets/README.md` and `odin/game/ui.odin`'s `CREDITS_PAGES` in step if an asset changes.
- [ ] Check the repo's own `LICENSE` and the vendored sheets' README files are still correct for what is redistributed.

## Shipping

- [x] Pushed October 12, 2026 from commit `1579592` with `tools/ship.sh --push`: build #2112264 on `thegrumpygamedev/tggd-lrj2025:html` (replaced the Blazor build #1355397). Check `butler status thegrumpygamedev/tggd-lrj2025:html` for the processed tick.
- [ ] After the push: paste `ITCH_DESCRIPTION.md`, set the embed square, check the live page.
- [ ] Hear the sound effects in a visible tab, and try the touch controls on a real phone (neither was possible in the development pane).
- [x] `src/` (the VB.NET reference) deleted October 12, 2026; recover with `git show 12900a0:src/...`. `Bit-Bonanza-*`/`Bountiful-Bits-*` stay (the generator reads them).
