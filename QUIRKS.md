# Quirks of the original, preserved by the exact port

The port reproduces the VB.NET game's behaviour. Each item here is something odd the original does that the port keeps
for now, to be **decided one at a time with the project owner** (keep, change, or remove). Percentages come from 500
generated worlds in the port (`odin/tests`), not from the original, which has no tests.

| # | Quirk | Where | Notes |
| --- | --- | --- | --- |
| 1 | Letter keys are case-sensitive: Caps Lock or Shift disables WASD/QZ | `Home.razor` CommandTable, `page/platform.js` | q is Left and z is Up (an AZERTY-ish table), as in the original |
| 2 | Moon people can spawn in the starting room (about 93% of worlds) and the ending room (about 94%) | `MoonPersonCharacterTypeDescriptor.CanSpawn` | it only excludes solid tiles, occupied tiles and the four tiles just inside each wall's door |
| 3 | About 4% of worlds start with a moon person next to the player | same | an attack of opportunity follows the first move |
| 4 | About half of the worlds (265 of 500) have a door that leads back into its own room | `WorldInitializer.InitializeSidePaths` | the candidate list for a side path includes the room itself; avg 1.5 such doors per world |
| 5 | Each map is picked uniformly before its tile, so a room's share of items does not depend on its size | `WorldInitializer.InitializeItemType` | the starting and ending rooms get as many items as an ordinary room |
| 6 | Keys start hidden under moon people (a key's spawn rule needs a non-player character on a room floor) | `KeyItemTypeDescriptor.CanSpawn` | probably deliberate; killing the moon person reveals the key |
| 7 | `World.Initialize` clears maps, characters, locations and the avatar but **not** items or queued messages | `World.Clear` | check in milestone 5 whether stale messages show on a new game |
| 8 | An empty spawn candidate list would crash the original (index into an empty list) | `RNG.FromEnumerable` | cannot happen with these counts; the port retries generation instead |
