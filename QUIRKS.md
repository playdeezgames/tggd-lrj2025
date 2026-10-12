# Quirks of the original, preserved by the exact port

The port reproduces the VB.NET game's behaviour. Each item here is something odd the original does that the port keeps
for now, to be **decided one at a time with the project owner** (keep, change, or remove). Percentages come from 500
generated worlds in the port (`odin/tests`), not from the original, which has no tests.

| # | Quirk | Where | Notes |
| --- | --- | --- | --- |
| 1 | ~~Letter keys are case-sensitive: Caps Lock or Shift disables WASD/QZ~~ **DECIDED (Oct 12, 2026): ignore case** | `Home.razor` CommandTable, `page/input.js` | q is Left and z is Up (an AZERTY-ish table), kept; Ctrl/Alt/Meta combinations are left to the browser |
| 2 | **DECIDED: no moon people in the starting room; the ending room is still allowed.** Moon people could spawn in the starting room (about 93% of worlds) and the ending room (about 94%) | `MoonPersonCharacterTypeDescriptor.CanSpawn` | it only excludes solid tiles, occupied tiles and the four tiles just inside each wall's door |
| 3 | **RESOLVED by 2.** About 4% of worlds started with a moon person next to the player | same | an attack of opportunity follows the first move |
| 4 | **DECIDED: keep.** About half of the worlds (265 of 500) have a door that leads back into its own room | `WorldInitializer.InitializeSidePaths` | the candidate list for a side path includes the room itself; avg 1.5 such doors per world |
| 5 | **DECIDED: keep.** Each map is picked uniformly before its tile, so a room's share of items does not depend on its size | `WorldInitializer.InitializeItemType` | the starting and ending rooms get as many items as an ordinary room |
| 6 | **DECIDED: keep.** Keys start hidden under moon people (a key's spawn rule needs a non-player character on a room floor) | `KeyItemTypeDescriptor.CanSpawn` | probably deliberate; killing the moon person reveals the key |
| 7 | `World.Initialize` clears maps, characters, locations and the avatar but **not** items or queued messages | `World.Clear` | no visible effect: messages are always empty when the game menu or the death screen is reachable; the port clears everything |
| 8 | An empty spawn candidate list would crash the original (index into an empty list) | `RNG.FromEnumerable` | cannot happen with these counts; the port retries generation instead |
| 9 | **DECIDED: keep.** Walking into a wall, a sign or a locked door counts as a move: it costs a satiety (or a health when starving) and gives adjacent moon people their free strike | `Character.AttemptMove` (`OnMove` runs after `Bump`) | opening a locked door uses a turn and does not move you |
| 10 | **DECIDED: keep.** The free strike when you leave a threatened tile happens **before** the move, and also when you drink a potion; attacking does not cost satiety and does not give *other* moon people a strike | `Character.HandleThreats` | |
| 11 | **DECIDED: show the real gain.** The potion message always said "+50 health" even when the heal was capped | `PotionItemTypeDescriptor.OnUse` | "you have 100/100" below it is correct |
| 12 | **DECIDED: play once, when the message appears.** A message's sound played on **every** refresh of the message screen, so pressing a non-confirm key replays it | `MessageState.Refresh` | applies in milestone 6 (UI) |
| 13 | (design, not asked) Moon people never move; they only strike back | `MoonPersonCharacterTypeDescriptor.OnMove` is empty | |
| 14 | Stepping through a door puts you on the far tile without checking for an occupant (it would overwrite one) | `DoorLocationTypeDescriptor.Bump` | cannot happen: spawning keeps moon people off those tiles |
| 15 | A moon person's sword and shield durability drift below zero as it fights (it has no minimum) | `OnHitEnemy`/`OnHitByEnemy` | no visible effect |
| 16 | **DECIDED: two lines ("N00b" / "misses!").** "N00b misses!" and "Moonie misses!" were one line wider than the 64-pixel screen and are clipped at both edges | `OnInteract` miss message, `MessageState` | the original's 6-pixel cells made them 72 and 84 wide; the port's font makes them 72 and 77, clipped the same way |
| 17 | The title's "TheGrumpyGameDev" line was exactly 64 wide in the original's monospace font; in the port's proportional font it is 68, so the port squeezes one pixel of spacing out of four glyphs | `TitleState.Refresh`, `write_centered_fitted` | a port adaptation, not an original quirk |

## Decided changes from the original

| Date | Change | Why |
| --- | --- | --- |
| 2026-10-12 | Letter keys ignore case (quirk 1) | Caps Lock silently disabled the controls |
| 2026-10-12 | Saving added (autosave each turn, Continue item, save removed on death or abandon) | not in the original; the owner's request |
| 2026-10-12 | Embark with a saved game asks "Lose save?" first | a misclick would lose a game in progress |
| 2026-10-12 | On-screen touch controls | phones have no keyboard |
| 2026-10-12 | No moon people spawn in the starting room (quirks 2, 3) | no world starts with a fight beside you |
| 2026-10-12 | The potion message shows the real gain (quirk 11) | it claimed +50 when 10 was gained |
| 2026-10-12 | A message's sound plays once, when it appears (quirk 12) | mashing keys repeated it |
| 2026-10-12 | Miss messages are two lines (quirk 16) | one line was clipped by the screen edge |
| 2026-10-12 | Kept as original: self-linking doors (4), room-first spawn picks (5), keys under moon people (6), bump costs (9), strike after drinking (10) | the owner's call |
