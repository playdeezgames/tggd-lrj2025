#+build !js
package tests

import "base:runtime"
import "core:fmt"
import "core:testing"
import "tggd:game"

Rig :: struct {
	core: ^game.Core,
	out:  game.Step_Output,
}

rig_new :: proc() -> Rig {
	r := Rig{core = new(game.Core)}
	game.core_init(r.core, {entropy = proc() -> u64 { return 5 }})
	game.core_step(r.core, {}, &r.out)
	return r
}
rig_free :: proc(r: ^Rig) { free(r.core); free_all(context.temp_allocator) }

// Sends commands one per step, as a player would.
play :: proc(r: ^Rig, commands: ..game.Command) {
	for c in commands { game.core_step(r.core, {events = {{command = c}}}, &r.out) }
}

@(test)
palette_has_24_hues_with_the_originals_values :: proc(t: ^testing.T) {
	palette := game.PALETTE
	testing.expect_value(t, len(palette), 24)
	testing.expect_value(t, palette[game.Hue.Black], 0xFF000000)
	testing.expect_value(t, palette[game.Hue.Brown], 0xFF0055AA) // #a50
	testing.expect_value(t, palette[game.Hue.White], 0xFFFFFFFF)
	testing.expect_value(t, palette[game.Hue.Dark_Red], 0xFF282880) // #802828
	testing.expect_value(t, palette[game.Hue.Medium_Gray], 0xFF808080)
	// the enum order is the original's numbering
	testing.expect_value(t, int(game.Hue.Light_Gray), 7)
	testing.expect_value(t, int(game.Hue.Darker_Gray), 16)
}

@(test)
first_step_presents_a_frame_and_an_idle_step_does_not :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	testing.expect(t, r.out.frame != nil)
	game.core_step(r.core, {}, &r.out)
	testing.expect(t, !r.out.frame_changed)
}

@(test)
rng_is_deterministic_and_in_range :: proc(t: ^testing.T) {
	a, b: game.Rng
	game.rng_seed(&a, 42)
	game.rng_seed(&b, 42)
	for _ in 0 ..< 1000 {
		x := game.rng_range(&a, 3, 9)
		testing.expect(t, x >= 3 && x <= 9)
		testing.expect_value(t, x, game.rng_range(&b, 3, 9))
	}
}

// ---- drawing engine, with a tiny font made here (the real font data is not chosen yet) ---------------
// A 2-high font with advance 3 holding 'A' (index 0) and 'B': A = top row full, bottom row left pixel; B = both rows right pixel.
test_font_rows := [4]u16{0b111, 0b001, 0b100, 0b100}
test_font_advance := [2]u8{3, 3}

test_font :: proc() -> game.Font {
	return {height = 2, first = 'A', count = 2, space = 3, advance = test_font_advance[:], rows = test_font_rows[:]}
}

@(test)
text_draws_set_pixels_only_and_returns_the_advance :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	font := test_font()
	game.fill_all(r.core, .Blue)
	end := game.write_text(r.core, &font, 10, 20, .White, "AB")
	testing.expect_value(t, end, 16)
	hue :: proc(c: ^game.Core, x, y: int) -> game.Hue { return game.Hue(c.hues[x + y * game.FRAME_WIDTH]) }
	testing.expect_value(t, hue(r.core, 10, 20), game.Hue.White) // A top row
	testing.expect_value(t, hue(r.core, 12, 20), game.Hue.White)
	testing.expect_value(t, hue(r.core, 10, 21), game.Hue.White) // A bottom-left
	testing.expect_value(t, hue(r.core, 11, 21), game.Hue.Blue)  // untouched: background shows through
	testing.expect_value(t, hue(r.core, 15, 20), game.Hue.White) // B right pixel, second glyph starts at 13
	testing.expect_value(t, hue(r.core, 13, 20), game.Hue.Blue)
}

@(test)
characters_outside_the_font_advance_but_draw_nothing :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	font := test_font()
	game.fill_all(r.core, .Black)
	end := game.write_text(r.core, &font, 0, 0, .White, "?A?")
	testing.expect_value(t, end, 9)
	testing.expect_value(t, game.text_width(&font, "?A?"), 9)
	testing.expect_value(t, game.Hue(r.core.hues[0]), game.Hue.Black)
	testing.expect_value(t, game.Hue(r.core.hues[3]), game.Hue.White) // 'A' at x = 3
}

@(test)
drawing_clips_at_every_edge_without_wrapping :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	font := test_font()
	game.fill_all(r.core, .Black)
	game.write_text(r.core, &font, -2, 0, .White, "A") // columns -2, -1 clipped; column 0 of the top row is the glyph's third pixel
	game.write_text(r.core, &font, 0, -1, .Yellow, "A") // top row clipped; the bottom row's left pixel lands at (0, 0)
	game.write_text(r.core, &font, game.FRAME_WIDTH - 1, 63, .Red, "A") // off the right and bottom edges
	testing.expect_value(t, game.Hue(r.core.hues[0]), game.Hue.Yellow)
	testing.expect_value(t, game.Hue(r.core.hues[game.FRAME_WIDTH - 1]), game.Hue.Black) // nothing wrapped to the row's far end
	testing.expect_value(t, game.Hue(r.core.hues[game.FRAME_WIDTH - 1 + 63 * game.FRAME_WIDTH]), game.Hue.Red)
	testing.expect_value(t, game.Hue(r.core.hues[0 + 1 * game.FRAME_WIDTH]), game.Hue.Black)
}

@(test)
centred_text_uses_the_integer_half_of_the_width :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	font := test_font()
	game.fill_all(r.core, .Black)
	game.write_centered(r.core, &font, 32, 0, .White, "A") // width 3, half 1 -> starts at 31
	testing.expect_value(t, game.Hue(r.core.hues[31]), game.Hue.White)
	testing.expect_value(t, game.Hue(r.core.hues[30]), game.Hue.Black)
}

// ---- sound queue -----------------------------------------------------------------------------------
@(test)
a_flood_of_sounds_is_capped_not_overrun :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	for _ in 0 ..< game.SFX_QUEUE_SIZE * 2 { game.play_sfx(r.core, .Eat) }
	testing.expect_value(t, r.core.sfx_count, game.SFX_QUEUE_SIZE)
}

@(test)
every_sound_has_a_wav_path :: proc(t: ^testing.T) {
	files := game.SFX_FILES
	for path, sfx in files {
		testing.expectf(t, len(path) > 4 && path[len(path) - 4:] == ".wav", "%v has no .wav path", sfx)
	}
	testing.expect_value(t, len(files), 12)
}

// ---- the real font data -----------------------------------------------------------------------------
@(test)
generated_fonts_have_the_expected_shapes :: proc(t: ^testing.T) {
	fonts := game.FONTS
	small, text, sprites := &fonts[.Small], &fonts[.Text], &fonts[.Sprites]
	testing.expect_value(t, small.height, 8)  // m3x6: 6 above the baseline, 2 below
	testing.expect_value(t, text.height, 9)   // m5x7: 7 above, 2 below
	testing.expect_value(t, sprites.height, 10)
	testing.expect_value(t, len(small.rows), small.count * small.height)
	testing.expect_value(t, len(text.rows), text.count * text.height)
	testing.expect_value(t, len(sprites.rows), sprites.count * sprites.height)
	testing.expect_value(t, len(small.advance), small.count)
	// the designer's advances from the vault note: m3x6 'i' 2, 'H' 4, 'M' 6; m5x7 'i' 3, 'H' 6, 'M' 8
	testing.expect_value(t, game.text_width(small, "iHM"), 2 + 4 + 6)
	testing.expect_value(t, game.text_width(text, "iHM"), 3 + 6 + 8)
	// HUD readouts like "H100 S100" fit the 64-pixel buffer with the small font
	testing.expect(t, game.text_width(small, "H100 S100 ") <= game.FRAME_WIDTH)
	// the title's widest line fits in the text font
	testing.expect(t, game.text_width(text, "SPLORR!!") <= game.FRAME_WIDTH)
}

@(test)
sprites_are_ten_wide_and_the_blank_is_empty :: proc(t: ^testing.T) {
	fonts := game.FONTS
	sprites := &fonts[.Sprites]
	testing.expect_value(t, game.glyph_advance(sprites, u8(game.Sprite.Player)), 10)
	for row in 0 ..< 10 { testing.expect_value(t, sprites.rows[int(game.Sprite.Blank) * 10 + row], 0) }
	// every drawn sprite has ink, and none uses a column beyond the tenth
	for sprite in game.Sprite.Player ..= game.Sprite.Threat {
		ink: u16
		for row in 0 ..< 10 { ink |= sprites.rows[int(sprite) * 10 + row] }
		testing.expectf(t, ink != 0, "%v is blank", sprite)
		testing.expectf(t, ink < 1 << 10, "%v spills past column 9", sprite)
	}
}

@(test)
a_queued_sound_comes_out_once_and_the_queue_clears :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	game.play_sfx(r.core, .Take)
	game.core_step(r.core, {}, &r.out)
	testing.expect_value(t, r.out.sfx_count, 1)
	testing.expect_value(t, r.out.sfx[0], game.Sfx.Take)
	game.core_step(r.core, {}, &r.out)
	testing.expect_value(t, r.out.sfx_count, 0)
}

// ---- the navigation picture ---------------------------------------------------------------------------
hue_at :: proc(c: ^game.Core, x, y: int) -> game.Hue { return game.Hue(c.hues[x + y * game.FRAME_WIDTH]) }

// Every set pixel of a sprite drawn at (x, y) must show `hue` (it is drawn last at that place).
expect_sprite_at :: proc(t: ^testing.T, c: ^game.Core, sprite: game.Sprite, x, y: int, hue: game.Hue, what: string) {
	fonts := game.FONTS
	sprites := &fonts[.Sprites]
	seen := 0
	for row in 0 ..< 10 {
		bits := sprites.rows[int(sprite) * 10 + row]
		for column in 0 ..< 10 {
			if bits & (1 << uint(column)) != 0 {
				seen += 1
				got := hue_at(c, x + column, y + row)
				if got != hue {
					testing.expectf(t, false, "%s: pixel (%d,%d) is %v, want %v", what, x + column, y + row, got, hue)
					return
				}
			}
		}
	}
	testing.expectf(t, seen > 0, "%s: the sprite has no pixels", what)
}

show :: proc(r: ^Rig, map_type: game.Map_Type, column, row: int) {
	game.debug_show_room(r.core, map_type, column, row)
	game.core_step(r.core, {}, &r.out)
}

@(test)
the_avatar_is_drawn_in_the_middle_of_the_view :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	show(&r, .Room, 7, 5)
	expect_sprite_at(t, r.core, .Player, 27, 27, .Brown, "avatar") // (64 - 10) / 2
	testing.expect(t, r.out.frame_changed)
}

@(test)
neighbours_are_ten_pixels_apart_and_layers_stack_floor_item_character :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	show(&r, .Room, 7, 5)
	// the debug room puts food east, a sword west, a shield south, a potion north, a moon person two east
	// (the food east of the avatar sits next to the moon person, so the threat marker is drawn over it: see below)
	expect_sprite_at(t, r.core, .Sword, 17, 27, .Light_Blue, "sword west")
	expect_sprite_at(t, r.core, .Shield, 27, 37, .Light_Green, "shield south")
	expect_sprite_at(t, r.core, .Potion, 27, 17, .Red, "potion north")
	expect_sprite_at(t, r.core, .Moon_Person, 47, 27, .Dark_Gray, "moon person")
	// a bare floor tile two up shows the floor sprite in its hue
	expect_sprite_at(t, r.core, .Floor, 27, 7, .Darker_Gray, "floor")
}

@(test)
tiles_next_to_another_character_show_the_threat_marker :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	show(&r, .Room, 7, 5)
	// the moon person at column 9 threatens its non-solid neighbours: column 8 (holding the food), 10 and rows above and below
	// the food tile is drawn first, then the marker over it
	expect_sprite_at(t, r.core, .Threat, 37, 27, .Dark_Red, "threat on the food tile")
	food_only := 0 // food pixels the marker does not cover keep the food's colour
	fonts := game.FONTS
	sprites := &fonts[.Sprites]
	for row in 0 ..< 10 { for column in 0 ..< 10 {
		food := sprites.rows[int(game.Sprite.Food) * 10 + row] & (1 << uint(column)) != 0
		threat := sprites.rows[int(game.Sprite.Threat) * 10 + row] & (1 << uint(column)) != 0
		if food && !threat {
			food_only += 1
			testing.expect_value(t, hue_at(r.core, 37 + column, 27 + row), game.Hue.Dark_Blue)
		}
	} }
	testing.expect(t, food_only > 0)
	// the tile west of the avatar has only the avatar next to it, which does not count: no marker there
	dark_red := 0
	for y in 27 ..< 37 { for x in 17 ..< 27 { if hue_at(r.core, x, y) == .Dark_Red { dark_red += 1 } } }
	testing.expect_value(t, dark_red, 0)
}

@(test)
the_room_edge_is_drawn_and_beyond_it_is_black :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	show(&r, .Starting_Room, 1, 1)
	// the top-left corner of the room is two tiles up and left: a gray wall; one further is off the map
	expect_sprite_at(t, r.core, .Wall, 17, 17, .Dark_Gray, "corner wall")
	for y in 8 ..< 18 { testing.expect_value(t, hue_at(r.core, 8, y), game.Hue.Black) }
	// the ending room's walls are blue
	show(&r, .Ending_Room, 1, 1)
	expect_sprite_at(t, r.core, .Wall, 17, 17, .Blue, "ending room wall")
}

@(test)
the_status_bars_show_health_satiety_and_the_pack :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	show(&r, .Room, 7, 5)
	// bars
	testing.expect_value(t, hue_at(r.core, 40, 0), game.Hue.Darker_Gray)
	testing.expect_value(t, hue_at(r.core, 40, 5), game.Hue.Darker_Gray)
	testing.expect_value(t, hue_at(r.core, 60, 60), game.Hue.Darker_Gray)
	// "H087 " in red from the left edge, then "S042 " in magenta
	reds, magentas := 0, 0
	for y in 0 ..< 6 {
		for x in 0 ..< 21 { if hue_at(r.core, x, y) == .Red { reds += 1 } }
		for x in 21 ..< 42 { if hue_at(r.core, x, y) == .Magenta { magentas += 1 } }
	}
	testing.expect(t, reds > 10)
	testing.expect(t, magentas > 10)
	// the pack along the bottom: food, potion, sword, shield, each ten wide, from x = 0 at y = 54
	food_pixels := 0
	for y in 54 ..< 64 { for x in 0 ..< 10 { if hue_at(r.core, x, y) == .Dark_Blue { food_pixels += 1 } } }
	testing.expect(t, food_pixels > 10)
	// the three keys down the right edge, five pixels apart, starting at x = 52, y = 0
	testing.expect(t, hue_at(r.core, 52 + 0, 0) != .Black || hue_at(r.core, 52 + 1, 1) != .Black)
}

@(test)
readouts_are_zero_padded_to_three_digits :: proc(t: ^testing.T) {
	buffer: [8]u8
	testing.expect_value(t, game.format_readout(buffer[:], 'H', 100), "H100 ")
	testing.expect_value(t, game.format_readout(buffer[:], 'S', 7), "S007 ")
	testing.expect_value(t, game.format_readout(buffer[:], 'H', 0), "H000 ")
	testing.expect_value(t, game.format_count(buffer[:], 0), "0")
	testing.expect_value(t, game.format_count(buffer[:], 25), "25")
}

@(test)
every_map_type_builds_a_full_grid_with_centred_doors :: proc(t: ^testing.T) {
	w := new(game.World); defer free(w)
	game.world_clear(w)
	start := game.add_map(w, .Starting_Room)
	end := game.add_map(w, .Ending_Room)
	room := game.add_map(w, .Room)
	for m in ([?]int{start, room}) {
		// doors sit at the middle of each wall and the sign at the centre
		for pos in ([?][2]int{{7, 0}, {7, 14}, {0, 7}, {14, 7}}) {
			testing.expect_value(t, w.locations[game.location_id(m, pos.x, pos.y)].location_type, game.Location_Type.Door)
		}
		testing.expect_value(t, w.locations[game.location_id(m, 7, 7)].location_type, game.Location_Type.Sign)
		testing.expect_value(t, w.locations[game.location_id(m, 0, 0)].location_type, game.Location_Type.Gray_Wall)
	}
	testing.expect_value(t, w.locations[game.location_id(start, 3, 3)].location_type, game.Location_Type.Starting_Room_Floor)
	testing.expect_value(t, w.locations[game.location_id(room, 3, 3)].location_type, game.Location_Type.Room_Floor)
	// the ending room: seven coloured doors and the final sign in the middle
	testing.expect_value(t, w.locations[game.location_id(end, 7, 7)].location_type, game.Location_Type.Final_Sign)
	testing.expect_value(t, w.locations[game.location_id(end, 7, 12)].location_type, game.Location_Type.Silver_Door)
	testing.expect_value(t, w.locations[game.location_id(end, 3, 7)].location_type, game.Location_Type.Gold_Door)
	// map ids follow creation order, and a location knows its place
	loc := w.locations[game.location_id(room, 4, 9)]
	testing.expect_value(t, int(loc.map_id), room)
	testing.expect_value(t, int(loc.column), 4)
	testing.expect_value(t, int(loc.row), 9)
	testing.expect_value(t, game.location_at(w, room, -1, 3), game.NONE)
	testing.expect_value(t, game.location_at(w, room, 15, 3), game.NONE)
}

@(test)
statistics_clamp_to_their_bounds_like_the_original :: proc(t: ^testing.T) {
	s: game.Stats
	game.stat_set_min(&s, .Health, 0)
	game.stat_set_max(&s, .Health, 100)
	game.stat_set(&s, .Health, 100)
	testing.expect_value(t, game.stat_change(&s, .Health, -130), 0)  // read back clamped
	testing.expect_value(t, game.stat_change(&s, .Health, 500), 100)
	testing.expect(t, !game.stat_has(&s, .Attack))
	testing.expect_value(t, game.stat_get(&s, .Attack), 0)
	testing.expect_value(t, game.stat_max(&s, .Attack), int(max(i32)))
}

// ---- world generation ---------------------------------------------------------------------------------
gen :: proc(seed: u64) -> ^game.World {
	w := new(game.World)
	rng: game.Rng
	game.rng_seed(&rng, seed)
	ok := game.generate_world(w, &rng)
	if !ok { free(w); return nil }
	return w
}

count_items :: proc(w: ^game.World, t: game.Item_Type) -> int {
	n := 0
	for i in 0 ..< w.item_count { if w.items[i].item_type == t { n += 1 } }
	return n
}

@(test)
a_generated_world_has_the_original_counts :: proc(t: ^testing.T) {
	w := gen(1); defer free(w)
	testing.expect(t, w != nil)
	if w == nil { return }
	testing.expect_value(t, w.map_count, 16)
	types: [game.Map_Type]int
	for i in 0 ..< w.map_count { types[w.map_types[i]] += 1 }
	testing.expect_value(t, types[.Starting_Room], 1)
	testing.expect_value(t, types[.Ending_Room], 1)
	testing.expect_value(t, types[.Room], 14)
	testing.expect_value(t, w.character_count, 41) // the player and 40 moon people
	testing.expect_value(t, w.item_count, 102)
	for key in game.Item_Type.Silver_Key ..= game.Item_Type.Emerald_Key { testing.expect_value(t, count_items(w, key), 1) }
	testing.expect_value(t, count_items(w, .Food), 50)
	testing.expect_value(t, count_items(w, .Sword), 10)
	testing.expect_value(t, count_items(w, .Shield), 10)
	testing.expect_value(t, count_items(w, .Potion), 25)
	// map order: starting room, ending room, then rooms
	testing.expect_value(t, w.map_types[0], game.Map_Type.Starting_Room)
	testing.expect_value(t, w.map_types[1], game.Map_Type.Ending_Room)
}

@(test)
the_avatar_starts_on_a_starting_room_floor :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(50) {
		w := gen(seed); defer free(w)
		avatar := w.characters[w.avatar]
		loc := w.locations[avatar.location]
		testing.expect_value(t, loc.location_type, game.Location_Type.Starting_Room_Floor)
		testing.expect_value(t, int(loc.character), w.avatar)
		testing.expect_value(t, avatar.character_type, game.Character_Type.N00b)
	}
}

@(test)
every_door_leads_to_a_floor_tile_and_the_way_back_returns_beside_it :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(100) {
		w := gen(seed); defer free(w)
		dirs := [game.Direction][2]int{.North = {7, 0}, .East = {14, 7}, .South = {7, 14}, .West = {0, 7}}
		inside := [game.Direction][2]int{.North = {7, 13}, .East = {1, 7}, .South = {7, 1}, .West = {13, 7}}
		opposite := game.DIRECTION_OPPOSITE
		for map_id in 0 ..< w.map_count {
			for d in game.Direction {
				door := w.locations[game.location_id(map_id, dirs[d].x, dirs[d].y)]
				dest := int(door.destination)
				ok := dest != game.NONE
				testing.expectf(t, ok, "seed %d map %d: %v door has no destination", seed, map_id, d)
				if !ok { continue }
				testing.expect(t, !game.is_solid(w.locations[dest].location_type))
				// it arrives just inside the far wall of the direction travelled
				to := w.locations[dest]
				testing.expect_value(t, [2]int{int(to.column), int(to.row)}, inside[d])
				// and that room's opposite door leads back to the tile just inside this door
				back_door := w.locations[game.location_id(int(to.map_id), dirs[opposite[d]].x, dirs[opposite[d]].y)]
				back := w.locations[int(back_door.destination)]
				testing.expect_value(t, int(back.map_id), map_id)
				testing.expect_value(t, [2]int{int(back.column), int(back.row)}, inside[opposite[d]])
			}
		}
	}
}

@(test)
the_main_path_numbers_the_rooms_and_reaches_the_ending_room :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(100) {
		w := gen(seed); defer free(w)
		// walk the numbered signs: room N's door to room N+1 exists, and sign numbers 1..15 each appear once
		seen: [16]int
		for map_id in 0 ..< w.map_count {
			n := int(w.locations[game.location_id(map_id, 7, 7)].room_number)
			if n != 0 { seen[n] += 1 }
		}
		for n in 1 ..= 15 { testing.expect_value(t, seen[n], 1) }
		testing.expect_value(t, seen[0], 0)
		// the ending room is unnumbered, the starting room is number 1
		testing.expect_value(t, int(w.locations[game.location_id(1, 7, 7)].room_number), 0)
		testing.expect_value(t, int(w.locations[game.location_id(0, 7, 7)].room_number), 1)
		// everything is reachable from the starting room through doors
		reached: [game.MAX_MAPS]bool
		stack: [game.MAX_MAPS]int
		sp := 1
		reached[0] = true
		dirs := [?][2]int{{7, 0}, {14, 7}, {7, 14}, {0, 7}}
		for sp > 0 {
			sp -= 1
			m := stack[sp]
			for d in dirs {
				dest := int(w.locations[game.location_id(m, d.x, d.y)].destination)
				next := int(w.locations[dest].map_id)
				if !reached[next] { reached[next] = true; stack[sp] = next; sp += 1 }
			}
		}
		for m in 0 ..< w.map_count { testing.expectf(t, reached[m], "seed %d: map %d unreachable", seed, m) }
	}
}

@(test)
keys_start_under_moon_people_on_room_floors :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(100) {
		w := gen(seed); defer free(w)
		for i in 0 ..< w.item_count {
			item := w.items[i]
			testing.expect_value(t, item.holder, game.Holder_Kind.Location)
			loc := w.locations[item.holder_id]
			testing.expect(t, !game.is_solid(loc.location_type))
			if game.is_key(item.item_type) {
				testing.expect_value(t, loc.location_type, game.Location_Type.Room_Floor)
				testing.expect(t, loc.character != game.NONE && int(loc.character) != w.avatar)
				testing.expect_value(t, w.characters[loc.character].character_type, game.Character_Type.Moon_Person)
			}
			// nothing starts on the player's tile
			testing.expect(t, int(item.holder_id) != int(w.characters[w.avatar].location))
		}
	}
}

@(test)
moon_people_avoid_the_tiles_inside_the_doors_and_each_other :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(100) {
		w := gen(seed); defer free(w)
		for c in 0 ..< w.character_count {
			ch := w.characters[c]
			loc := w.locations[ch.location]
			testing.expect_value(t, int(loc.character), c) // one character per tile, and the tile knows it
			if ch.character_type != .Moon_Person { continue }
			col, row := int(loc.column), int(loc.row)
			testing.expect(t, !(col == 1 && row == 7) && !(col == 13 && row == 7) && !(col == 7 && row == 1) && !(col == 7 && row == 13))
			testing.expect(t, !game.is_solid(loc.location_type))
			testing.expect_value(t, ch.stats[.Health].value, 25)
		}
	}
}

@(test)
generation_is_deterministic_for_a_seed_and_differs_between_seeds :: proc(t: ^testing.T) {
	a, b, c := gen(77), gen(77), gen(78)
	defer { free(a); free(b); free(c) }
	testing.expect(t, a^ == b^)
	testing.expect(t, a^ != c^)
}

@(test)
items_carry_the_original_statistics :: proc(t: ^testing.T) {
	w := gen(3); defer free(w)
	seen: [game.Item_Type]bool
	for i in 0 ..< w.item_count {
		item := &w.items[i]
		seen[item.item_type] = true
		#partial switch item.item_type {
		case .Sword:
			testing.expect_value(t, game.stat_get(&item.stats, .Attack), 20)
			testing.expect_value(t, game.stat_get(&item.stats, .Sword_Durability), 5)
		case .Shield:
			testing.expect_value(t, game.stat_get(&item.stats, .Defend), 10)
			testing.expect_value(t, game.stat_get(&item.stats, .Shield_Durability), 5)
		case .Potion:
			testing.expect_value(t, game.stat_get(&item.stats, .Health), 50)
		}
	}
	for t2 in game.Item_Type { testing.expectf(t, seen[t2], "%v never generated", t2) }
}

@(test)
many_seeds_generate_without_giving_up :: proc(t: ^testing.T) {
	failures := 0
	for seed in 0 ..< u64(300) {
		w := gen(seed * 7919 + 13)
		if w == nil { failures += 1 } else { free(w) }
	}
	testing.expect_value(t, failures, 0)
}

// ---- rules ---------------------------------------------------------------------------------------------
// A bare room (map 0, ordinary room terrain) with the player at (5, 5). Returns the core to poke at.
scene :: proc(r: ^Rig) -> ^game.Core {
	c := r.core
	game.world_clear(&c.world)
	game.add_map(&c.world, .Room)
	c.world.avatar = game.add_character(&c.world, .N00b, game.location_id(0, 5, 5))
	return c
}

at :: proc(column, row: int) -> int { return game.location_id(0, column, row) }

moon :: proc(c: ^game.Core, column, row: int) -> int {
	return game.add_character(&c.world, .Moon_Person, at(column, row))
}

put :: proc(c: ^game.Core, t: game.Item_Type, column, row: int) -> int {
	item := game.add_item(&c.world, t)
	c.world.items[item].stats = game.item_initial_stats(t)
	game.give_item(&c.world, item, .Location, at(column, row))
	return item
}

carry :: proc(c: ^game.Core, t: game.Item_Type) -> int {
	item := game.add_item(&c.world, t)
	c.world.items[item].stats = game.item_initial_stats(t)
	game.give_item(&c.world, item, .Character, c.world.avatar)
	return item
}

avatar_at :: proc(c: ^game.Core) -> (column, row: int) {
	loc := c.world.locations[c.world.characters[c.world.avatar].location]
	return int(loc.column), int(loc.row)
}

stat :: proc(c: ^game.Core, character: int, s: game.Stat) -> int {
	return game.stat_get(&c.world.characters[character].stats, s)
}

// Message i as "line|line|line".
message_text :: proc(c: ^game.Core, i: int) -> string {
	m := &c.world.messages[i]
	text := ""
	for l in 0 ..< int(m.line_count) {
		line := string(m.lines[l].text[:m.lines[l].len])
		text = line if l == 0 else fmt.tprintf("%s|%s", text, line)
	}
	return text
}

@(test)
walking_onto_floor_moves_and_costs_a_satiety :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	game.attempt_move(c, c.world.avatar, .East)
	col, row := avatar_at(c)
	testing.expect_value(t, col, 6)
	testing.expect_value(t, row, 5)
	testing.expect_value(t, c.world.locations[at(5, 5)].character, i16(game.NONE))
	testing.expect_value(t, stat(c, c.world.avatar, .Satiety), 99)
	testing.expect_value(t, c.world.message_count, 0)
}

@(test)
bumping_a_wall_stays_put_but_still_costs_a_satiety :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	game.move_character_to(&c.world, c.world.avatar, at(1, 5))
	game.attempt_move(c, c.world.avatar, .West) // (0, 5) is a gray wall
	col, _ := avatar_at(c)
	testing.expect_value(t, col, 1)
	testing.expect_value(t, stat(c, c.world.avatar, .Satiety), 99)
}

@(test)
signs_say_their_room_number_and_the_final_sign_asks_the_question :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	c.world.locations[at(7, 7)].room_number = 9
	game.move_character_to(&c.world, c.world.avatar, at(6, 7))
	game.attempt_move(c, c.world.avatar, .East)
	testing.expect_value(t, c.world.message_count, 1)
	testing.expect_value(t, message_text(c, 0), "Room#9")
	game.set_location_type(&c.world, at(7, 7), .Final_Sign)
	game.attempt_move(c, c.world.avatar, .East)
	testing.expect_value(t, message_text(c, 1), "Have you|checked|yer|butthole?")
}

@(test)
a_door_carries_the_player_to_its_destination_and_picks_things_up_there :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	game.add_map(&c.world, .Room)
	c.world.locations[at(7, 0)].destination = i16(game.location_id(1, 7, 13))
	game.move_character_to(&c.world, c.world.avatar, at(7, 1))
	put(c, .Food, 7, 13) // map 0 (the same room layout): irrelevant, check the other room below
	item := game.add_item(&c.world, .Potion)
	game.give_item(&c.world, item, .Location, game.location_id(1, 7, 13))
	game.attempt_move(c, c.world.avatar, .North)
	loc := c.world.locations[c.world.characters[c.world.avatar].location]
	testing.expect_value(t, int(loc.map_id), 1)
	testing.expect_value(t, int(loc.column), 7)
	testing.expect_value(t, int(loc.row), 13)
	testing.expect_value(t, c.world.items[item].holder, game.Holder_Kind.Character) // collected on arrival
	testing.expect_value(t, message_text(c, 0), "<space>|to drink|potion.")
}

@(test)
locked_doors_need_their_key_and_become_floor :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	game.set_location_type(&c.world, at(5, 4), .Gold_Door)
	game.attempt_move(c, c.world.avatar, .North)
	testing.expect_value(t, c.world.locations[at(5, 4)].location_type, game.Location_Type.Gold_Door)
	testing.expect_value(t, c.sfx_queue[c.sfx_count - 1], game.Sfx.Shucks)
	carry(c, .Silver_Key) // the wrong key
	game.attempt_move(c, c.world.avatar, .North)
	testing.expect_value(t, c.world.locations[at(5, 4)].location_type, game.Location_Type.Gold_Door)
	key := carry(c, .Gold_Key)
	game.attempt_move(c, c.world.avatar, .North)
	testing.expect_value(t, c.world.locations[at(5, 4)].location_type, game.Location_Type.Ending_Room_Floor)
	testing.expect_value(t, c.world.items[key].holder, game.Holder_Kind.None)
	testing.expect_value(t, c.sfx_queue[c.sfx_count - 1], game.Sfx.Woo_Hoo)
	_, row := avatar_at(c)
	testing.expect_value(t, row, 5) // opening it does not move you
	game.attempt_move(c, c.world.avatar, .North)
	_, row = avatar_at(c)
	testing.expect_value(t, row, 4)
}

@(test)
the_first_sword_is_wielded_and_later_ones_are_spares :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	first := put(c, .Sword, 6, 5)
	game.attempt_move(c, a, .East)
	testing.expect_value(t, stat(c, a, .Attack), 20)
	testing.expect_value(t, stat(c, a, .Sword_Durability), 5)
	testing.expect_value(t, c.world.items[first].holder, game.Holder_Kind.None) // used up, not carried
	testing.expect_value(t, message_text(c, 0), "You got|a sword!")
	second := put(c, .Sword, 7, 5)
	game.attempt_move(c, a, .East)
	testing.expect_value(t, c.world.items[second].holder, game.Holder_Kind.Character)
	testing.expect_value(t, message_text(c, 1), "Good to|have a|back-up!")
	testing.expect_value(t, c.sfx_queue[0], game.Sfx.Yoink)
}

@(test)
hints_appear_once_per_kind :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	put(c, .Food, 6, 5); put(c, .Food, 7, 5); put(c, .Silver_Key, 8, 5)
	for _ in 0 ..< 3 { game.attempt_move(c, c.world.avatar, .East) }
	testing.expect_value(t, c.world.message_count, 2) // one food hint, one key hint
	testing.expect_value(t, message_text(c, 0), "Blueberry|(fer when|yer|hungry!)")
	testing.expect_value(t, message_text(c, 1), "Save keys|to open|doors")
	testing.expect_value(t, game.item_type_count(&c.world, .Character, c.world.avatar, .Food), 2)
}

@(test)
attacking_a_moon_person_trades_blows :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	m := moon(c, 6, 5)
	game.attempt_move(c, a, .East)
	// the player hits for 10 - 0, the moon person (25 health) has 15 left and strikes back for 20 - 5
	testing.expect_value(t, stat(c, m, .Health), 15)
	testing.expect_value(t, stat(c, a, .Health), 85)
	testing.expect_value(t, c.world.message_count, 2)
	testing.expect_value(t, message_text(c, 0), "N00b|hits|for 10!|15 left!")
	testing.expect_value(t, message_text(c, 1), "Moonie|hits|for 15!|85 left!")
	testing.expect_value(t, c.world.messages[0].sfx, game.Sfx.Enemy_Hit) // the sound of the target being hit
	testing.expect_value(t, c.world.messages[1].sfx, game.Sfx.Player_Hit)
	col, _ := avatar_at(c)
	testing.expect_value(t, col, 5)                                     // attacking does not move you
	testing.expect_value(t, stat(c, a, .Satiety), 100)                  // and costs no satiety
}

@(test)
killing_a_moon_person_reveals_what_it_stood_on :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	m := moon(c, 6, 5)
	key := put(c, .Ruby_Key, 6, 5)
	for _ in 0 ..< 3 { game.attempt_move(c, a, .East) }
	testing.expect(t, game.is_dead(&c.world, m))
	testing.expect_value(t, c.world.locations[at(6, 5)].character, i16(game.NONE))
	testing.expect_value(t, c.world.items[key].holder, game.Holder_Kind.Location)
	// hit, counter, hit, counter, then the killing blow: no "left" line, a kill message, and no counter
	testing.expect_value(t, message_text(c, c.world.message_count - 2), "N00b|hits|for 10!")
	testing.expect_value(t, message_text(c, c.world.message_count - 1), "N00b|kills|Moonie!")
	testing.expect_value(t, c.world.messages[c.world.message_count - 1].sfx, game.Sfx.Enemy_Death)
	testing.expect_value(t, stat(c, a, .Health), 70) // only two counter-strikes landed
}

@(test)
leaving_a_threatened_tile_gives_a_free_strike_first :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	moon(c, 6, 5)
	game.attempt_move(c, a, .West) // step away from the moon person next to us
	testing.expect_value(t, stat(c, a, .Health), 85)
	testing.expect_value(t, message_text(c, 0), "Moonie|hits|for 15!|85 left!")
	col, _ := avatar_at(c)
	testing.expect_value(t, col, 4)
	game.attempt_move(c, a, .West) // out of reach: nothing happens
	testing.expect_value(t, stat(c, a, .Health), 85)
	testing.expect_value(t, c.world.message_count, 1)
}

@(test)
a_sword_wears_out_and_the_next_spare_takes_over :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	stat_set := game.stat_set
	stat_set(&c.world.characters[a].stats, .Attack, 20)
	stat_set(&c.world.characters[a].stats, .Sword_Durability, 1)
	spare := carry(c, .Sword)
	m := moon(c, 6, 5)
	stat_set(&c.world.characters[m].stats, .Defend, 5) // so the hit is 15, not enough to kill
	game.attempt_move(c, a, .East)
	// the hit message, the counter, then the sword breaks (one spare left, none after it)
	found := false
	for i in 0 ..< c.world.message_count {
		if message_text(c, i) == "Yer sword|broke!|Equipping|next one!|(0 left)" { found = true }
	}
	testing.expect(t, found)
	testing.expect_value(t, stat(c, a, .Sword_Durability), 5)
	testing.expect_value(t, c.world.items[spare].holder, game.Holder_Kind.None)
	// with no spare, the last sword breaks and the bare-handed attack returns
	stat_set(&c.world.characters[a].stats, .Sword_Durability, 1)
	game.attempt_move(c, a, .East)
	testing.expect_value(t, stat(c, a, .Attack), 10)
}

@(test)
hunger_eats_when_empty_and_wounds_when_there_is_nothing_to_eat :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	game.stat_set(&c.world.characters[a].stats, .Satiety, 0)
	game.attempt_move(c, a, .East)
	testing.expect_value(t, stat(c, a, .Satiety), 0)
	testing.expect_value(t, stat(c, a, .Health), 99) // nothing to eat
	food := carry(c, .Food)
	game.attempt_move(c, a, .East)
	testing.expect_value(t, stat(c, a, .Satiety), 25)
	testing.expect_value(t, stat(c, a, .Health), 99)
	testing.expect_value(t, c.world.items[food].holder, game.Holder_Kind.None)
	testing.expect_value(t, message_text(c, 0), "Hungry?|Blueberries|satisfy!")
	testing.expect(t, c.sfx_count > 0 && c.sfx_queue[c.sfx_count - 1] == .Eat)
}

@(test)
starving_to_death_kills_without_a_message :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	game.stat_set(&c.world.characters[a].stats, .Satiety, 0)
	game.stat_set(&c.world.characters[a].stats, .Health, 1)
	game.attempt_move(c, a, .East)
	testing.expect(t, game.is_dead(&c.world, a))
	testing.expect_value(t, c.world.message_count, 0)
}

@(test)
potions_heal_up_to_the_maximum_and_say_so :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	game.attempt_use_item_of_type(c, a, .Potion)
	testing.expect_value(t, message_text(c, 0), "You have|no Potion")
	game.stat_set(&c.world.characters[a].stats, .Health, 80)
	carry(c, .Potion)
	game.attempt_use_item_of_type(c, a, .Potion)
	testing.expect_value(t, stat(c, a, .Health), 100)
	testing.expect_value(t, message_text(c, 1), "+50 health|you have|100/100")
	testing.expect_value(t, game.item_type_count(&c.world, .Character, a, .Potion), 0)
}

@(test)
dying_in_a_fight_clears_the_tile_and_ends_with_a_kill_message :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	game.stat_set(&c.world.characters[a].stats, .Health, 10)
	moon(c, 6, 5)
	game.attempt_move(c, a, .East)
	testing.expect(t, game.is_dead(&c.world, a))
	testing.expect_value(t, c.world.locations[at(5, 5)].character, i16(game.NONE))
	testing.expect_value(t, message_text(c, c.world.message_count - 1), "Moonie|kills|N00b!")
	testing.expect_value(t, c.world.messages[c.world.message_count - 1].sfx, game.Sfx.Player_Death)
}

@(test)
messages_dismiss_in_order_and_a_full_queue_drops_extras :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	a := c.world.avatar
	game.add_message(c, a, .Take, "one")
	game.add_message(c, a, nil, "two")
	game.add_message(c, 99, nil, "not the avatar's") // other characters are told nothing
	testing.expect_value(t, c.world.message_count, 2)
	testing.expect_value(t, game.current_message_line(&c.world, 0), "one")
	game.dismiss_message(&c.world)
	testing.expect_value(t, game.current_message_line(&c.world, 0), "two")
	game.dismiss_message(&c.world)
	game.dismiss_message(&c.world) // dismissing nothing is harmless
	testing.expect_value(t, c.world.message_count, 0)
	for _ in 0 ..< game.MAX_MESSAGES + 5 { game.add_message(c, a, nil, "x") }
	testing.expect_value(t, c.world.message_count, game.MAX_MESSAGES)
}

@(test)
a_random_walk_never_breaks_the_world_invariants :: proc(t: ^testing.T) {
	// 20 worlds, 3000 random commands each (moves and potion use), checking after every step that the occupancy
	// bookkeeping agrees, the avatar is somewhere sensible, and nothing overflows. Stops at death.
	r := rig_new(); defer rig_free(&r)
	c := r.core
	for seed in 0 ..< u64(20) {
		rng: game.Rng
		game.rng_seed(&rng, seed + 1000)
		ok := game.generate_world(&c.world, &rng)
		testing.expect(t, ok)
		for _ in 0 ..< 3000 {
			if game.is_dead(&c.world, c.world.avatar) { break }
			roll := game.rng_range(&rng, 0, 9)
			if roll == 9 {
				game.attempt_use_item_of_type(c, c.world.avatar, .Potion)
			} else {
				game.attempt_move(c, c.world.avatar, game.Direction(roll % 4))
			}
			for game.has_messages(&c.world) { game.dismiss_message(&c.world) }
			c.sfx_count = 0
			free_all(context.temp_allocator)
			w := &c.world
			for i in 0 ..< w.character_count {
				ch := &w.characters[i]
				if game.is_dead(w, i) { continue }
				if int(w.locations[ch.location].character) != i {
					testing.expectf(t, false, "seed %d: character %d is not on its location", seed, i)
					return
				}
			}
			avatar := w.characters[w.avatar]
			testing.expect(t, game.stat_get(&avatar.stats, .Satiety) >= 0 && game.stat_get(&avatar.stats, .Satiety) <= 100)
			testing.expect(t, game.stat_get(&avatar.stats, .Health) >= 0 && game.stat_get(&avatar.stats, .Health) <= 100)
		}
	}
}

// ---- screens ---------------------------------------------------------------------------------------------
// Presses commands one per step and returns the screen afterwards.
press_all :: proc(r: ^Rig, commands: ..game.Command) -> game.Screen {
	for c in commands { game.core_step(r.core, {events = {{command = c}}}, &r.out) }
	return r.core.screen
}

queued_sfx :: proc(r: ^Rig) -> int { return r.out.sfx_count }

@(test)
the_game_boots_on_the_title_and_space_opens_the_menu :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	testing.expect_value(t, r.core.screen, game.Screen.Title)
	testing.expect_value(t, press_all(&r, .Up, .Down, .Red, .Blue, .Yellow), game.Screen.Title)
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Main_Menu)
	testing.expect_value(t, press_all(&r, .Red), game.Screen.Main_Menu) // nothing to cancel to
}

@(test)
menus_wrap_around_at_both_ends :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	press_all(&r, .Green)
	testing.expect_value(t, r.core.menu_index, 0)
	press_all(&r, .Up)
	testing.expect_value(t, r.core.menu_index, 1)
	press_all(&r, .Down)
	testing.expect_value(t, r.core.menu_index, 0)
	press_all(&r, .Down, .Down)
	testing.expect_value(t, r.core.menu_index, 0)
}

@(test)
the_highlighted_menu_item_is_centred_with_a_bar :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	press_all(&r, .Green) // main menu, first item highlighted
	// rows 28..36 (32 - 9/2 = 28, 9 high) are the bar, in the item hue; the second item below is unhighlighted
	testing.expect_value(t, hue_at(r.core, 0, 28), game.Hue.Light_Gray)
	testing.expect_value(t, hue_at(r.core, 63, 36), game.Hue.Light_Gray)
	testing.expect_value(t, hue_at(r.core, 0, 27), game.Hue.Black)
	testing.expect_value(t, hue_at(r.core, 0, 37), game.Hue.Black)
	press_all(&r, .Down) // the bar stays put and the list scrolls under it
	testing.expect_value(t, hue_at(r.core, 0, 28), game.Hue.Light_Gray)
	testing.expect_value(t, hue_at(r.core, 0, 19), game.Hue.Black) // the first item is now above, unhighlighted
}

@(test)
the_tutorial_waits_for_each_command_in_order :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	press_all(&r, .Green, .Green) // title, then Tutorial
	testing.expect_value(t, r.core.screen, game.Screen.Tutorial)
	testing.expect_value(t, press_all(&r, .Down, .Left, .Green), game.Screen.Tutorial) // wrong first command
	testing.expect_value(t, r.core.tutorial_step, 0)
	testing.expect_value(t, press_all(&r, .Up, .Up), game.Screen.Tutorial) // step 2 wants Down
	testing.expect_value(t, r.core.tutorial_step, 1)
	testing.expect_value(t, press_all(&r, .Down, .Left, .Right, .Green), game.Screen.Tutorial)
	testing.expect_value(t, r.core.tutorial_step, 5)
	testing.expect_value(t, press_all(&r, .Red), game.Screen.Main_Menu)
}

@(test)
embark_builds_a_world_and_starts_play :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	testing.expect_value(t, press_all(&r, .Green, .Down, .Green), game.Screen.Navigation)
	testing.expect_value(t, r.core.world.map_count, 16)
	testing.expect(t, r.core.world.avatar != game.NONE)
}

play_world :: proc(r: ^Rig) {
	press_all(r, .Green, .Down, .Green)
}

@(test)
direction_commands_move_the_player_and_red_opens_the_game_menu :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	c.screen = .Navigation
	c.dirty = true
	before := c.world.characters[c.world.avatar].location
	press_all(&r, .Right)
	testing.expect(t, c.world.characters[c.world.avatar].location != before)
	testing.expect_value(t, c.screen, game.Screen.Navigation)
	testing.expect_value(t, press_all(&r, .Red), game.Screen.Game_Menu)
	testing.expect_value(t, press_all(&r, .Red), game.Screen.Navigation)
	testing.expect_value(t, press_all(&r, .Red, .Green), game.Screen.Navigation) // Continue
}

@(test)
abandoning_needs_a_yes_and_returns_to_the_menu_with_nothing_left :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	play_world(&r)
	press_all(&r, .Red, .Down, .Green) // game menu, Abandon
	testing.expect_value(t, r.core.screen, game.Screen.Confirm_Abandon)
	testing.expect_value(t, r.core.menu_index, 0) // No is first
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Game_Menu)
	press_all(&r, .Down, .Green, .Red) // Abandon again, then cancel with Red
	testing.expect_value(t, r.core.screen, game.Screen.Game_Menu)
	press_all(&r, .Down, .Green, .Down, .Green) // Abandon, Yes
	testing.expect_value(t, r.core.screen, game.Screen.Main_Menu)
	testing.expect_value(t, r.core.world.map_count, 0)
	testing.expect_value(t, r.core.world.avatar, game.NONE)
	testing.expect_value(t, press_all(&r, .Down, .Green), game.Screen.Navigation) // and a new game starts fine
}

@(test)
the_potion_key_asks_first_and_complains_when_there_is_none :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	c.screen = .Navigation
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Message) // no potion
	testing.expect_value(t, message_text(c, 0), "You have|no Potion")
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Navigation)
	carry(c, .Potion)
	game.stat_set(&c.world.characters[c.world.avatar].stats, .Health, 40)
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Confirm_Potion)
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Navigation) // No (the first item)
	testing.expect_value(t, stat(c, c.world.avatar, .Health), 40)
	press_all(&r, .Green, .Down, .Green) // Yes
	testing.expect_value(t, stat(c, c.world.avatar, .Health), 90)
	testing.expect_value(t, r.core.screen, game.Screen.Message)
	testing.expect_value(t, message_text(c, 0), "+50 health|you have|90/100")
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Navigation)
}

@(test)
only_the_confirm_key_dismisses_a_message_and_its_sound_replays_on_other_keys :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	c.screen = .Navigation
	moon(c, 6, 5)
	testing.expect_value(t, press_all(&r, .Right), game.Screen.Message) // attack: two messages
	testing.expect_value(t, c.world.message_count, 2)
	testing.expect_value(t, r.out.sfx_count, 1) // the first message's sound, played on showing it
	testing.expect_value(t, r.out.sfx[0], game.Sfx.Enemy_Hit)
	testing.expect_value(t, press_all(&r, .Up), game.Screen.Message)
	testing.expect_value(t, r.out.sfx_count, 1) // a quirk: it plays again
	testing.expect_value(t, press_all(&r, .Red, .Left, .Blue), game.Screen.Message)
	testing.expect_value(t, c.world.message_count, 2)
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Message) // the second message
	testing.expect_value(t, r.out.sfx[0], game.Sfx.Player_Hit)
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Navigation)
}

@(test)
dying_shows_the_messages_then_the_dead_screen_then_the_menu :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	c := scene(&r)
	c.screen = .Navigation
	game.stat_set(&c.world.characters[c.world.avatar].stats, .Health, 10)
	moon(c, 6, 5)
	press_all(&r, .Right)
	for c.screen == .Message { press_all(&r, .Green) }
	testing.expect_value(t, c.screen, game.Screen.Dead)
	testing.expect_value(t, press_all(&r, .Up, .Red, .Left), game.Screen.Dead)
	testing.expect_value(t, press_all(&r, .Green), game.Screen.Main_Menu)
	testing.expect_value(t, c.world.avatar, game.NONE)
}

@(test)
every_screen_draws_something_and_text_that_fit_the_original_still_fits :: proc(t: ^testing.T) {
	fonts := game.FONTS
	text, small := &fonts[.Text], &fonts[.Small]
	too_wide := 0
	check :: proc(t: ^testing.T, font: ^game.Font, s: string, limit: int) {
		w := game.text_width(font, s)
		testing.expectf(t, w <= limit, "%q is %d wide (limit %d)", s, w, limit)
	}
	for line in ([?]string{"The", "Blue", "Room", "of", "SPLORR!!"}) { check(t, text, line, 62) } // shadowed by one pixel
	for line in ([?]string{"lowrezjam-2025", "<space>"}) { check(t, small, line, 64) }
	// "TheGrumpyGameDev" is 4 pixels too wide and is squeezed (write_centered_fitted)
	testing.expect_value(t, game.text_width(small, "TheGrumpyGameDev"), 68)
	for step in game.TUTORIAL_STEPS { for line in step.text { check(t, text, line, 64) } }
	for item in ([?]string{"Tutorial", "Embark!", "Continue", "Abandon", "No", "Yes", "Abandon?", "Yer Dead!", "Lose save?"}) { check(t, text, item, 64) }
	check(t, small, "Use Potion?", 64)
	for line in ([?]string{"You got", "a sword!", "a shield!", "Good to", "have a", "back-up!", "Yer sword", "broke!", "Equipping",
		"next one!", "(10 left)", "Yer last", "Yer shield", "Save keys", "to open", "doors", "Blueberry", "(fer when", "yer",
		"hungry!)", "Hungry?", "Blueberries", "satisfy!", "<space>", "to drink", "potion.", "+50 health", "you have", "100/100",
		"You have", "no Potion", "Have you", "checked", "butthole?", "Room#15", "N00b", "Moonie", "hits", "for 20!", "85 left!",
		"kills", "Moonie!", "N00b!"}) {
		check(t, text, line, 64)
	}
	_ = too_wide
}

@(test)
fitted_text_stays_inside_the_frame_and_still_draws_every_glyph :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	fonts := game.FONTS
	small := &fonts[.Small]
	game.fill_all(r.core, .Black)
	game.write_centered_fitted(r.core, small, 32, 10, .White, "TheGrumpyGameDev", 64)
	leftmost, rightmost, ink := 64, -1, 0
	for y in 10 ..< 18 { for x in 0 ..< 64 {
		if hue_at(r.core, x, y) == .White { ink += 1; leftmost = min(leftmost, x); rightmost = max(rightmost, x) }
	} }
	testing.expect(t, leftmost >= 0 && rightmost <= 63)
	testing.expect(t, rightmost - leftmost >= 58) // nearly the whole width is used
	// every glyph's pixels are there: the lit count equals the glyphs' own ink (squeezed glyphs must not overlap)
	expected := 0
	for char in transmute([]u8)string("TheGrumpyGameDev") {
		for row in 0 ..< small.height {
			bits := small.rows[(int(char) - small.first) * small.height + row]
			for bit in 0 ..< 16 { if bits & (1 << uint(bit)) != 0 { expected += 1 } }
		}
	}
	testing.expect_value(t, ink, expected)
}

// ---- saving ---------------------------------------------------------------------------------------------
// A one-slot fake of browser storage (a game only ever uses one key).
Fake_Store :: struct {
	key:     [64]u8,
	key_len: int,
	value:   [game.SAVE_BUFFER_SIZE]u8,
	len:     int,
	has:     bool,
	writes:  int,
	removes: int,
	refuse:  bool, // quota exceeded
}
store: Fake_Store

store_reset :: proc() { store = {} }

store_get :: proc(key: string, allocator: runtime.Allocator) -> (value: string, ok: bool) {
	if !store.has || key != string(store.key[:store.key_len]) { return "", false }
	buf := make([]u8, store.len, allocator)
	copy(buf, store.value[:store.len])
	return string(buf), true
}

store_set :: proc(key, value: string) -> bool {
	if store.refuse { return false }
	copy(store.key[:], key)
	store.key_len = len(key)
	copy(store.value[:], value)
	store.len = len(value)
	store.has = true
	store.writes += 1
	return true
}

store_remove :: proc(key: string) {
	store.has = false
	store.removes += 1
}

saving_rig :: proc() -> Rig {
	r := Rig{core = new(game.Core)}
	game.core_init(r.core, {
		entropy = proc() -> u64 { return 5 },
		storage_get = store_get, storage_set = store_set, storage_remove = store_remove,
	})
	game.core_step(r.core, {}, &r.out)
	return r
}

stored :: proc() -> string { return string(store.value[:store.len]) }

@(test)
the_world_round_trips_through_a_save_exactly :: proc(t: ^testing.T) {
	for seed in 0 ..< u64(10) {
		w := gen(seed + 400); defer free(w)
		// play a while so there are spent doors, dead moon people, held items, tags and queued messages
		r := rig_new(); defer rig_free(&r)
		r.core.world = w^
		rng: game.Rng
		game.rng_seed(&rng, seed)
		for _ in 0 ..< 400 {
			if game.is_dead(&r.core.world, r.core.world.avatar) { break }
			game.attempt_move(r.core, r.core.world.avatar, game.Direction(game.rng_range(&rng, 0, 3)))
			if game.rng_range(&rng, 0, 3) != 0 { for game.has_messages(&r.core.world) { game.dismiss_message(&r.core.world) } }
		}
		if game.is_dead(&r.core.world, r.core.world.avatar) { continue }
		buf := make([]u8, game.SAVE_BUFFER_SIZE); defer delete(buf)
		text, ok := game.encode_world(&r.core.world, buf)
		testing.expect(t, ok)
		back := new(game.World); defer free(back)
		testing.expect(t, game.decode_world(text, back))
		testing.expect(t, back^ == r.core.world)
		free_all(context.temp_allocator)
	}
}

@(test)
a_fresh_world_save_is_well_under_the_buffer :: proc(t: ^testing.T) {
	w := gen(1); defer free(w)
	buf := make([]u8, game.SAVE_BUFFER_SIZE); defer delete(buf)
	text, ok := game.encode_world(w, buf)
	testing.expect(t, ok)
	testing.expect(t, len(text) < 100 * 1024)
	testing.expect(t, len(text) > 1000)
	testing.expect_value(t, text[:len(game.SAVE_HEADER)], game.SAVE_HEADER)
}

@(test)
every_turn_is_saved_under_a_namespaced_key_and_death_or_abandoning_removes_it :: proc(t: ^testing.T) {
	store_reset()
	r := saving_rig(); defer rig_free(&r)
	testing.expect(t, game.SAVE_KEY == "tggd-lrj2025:save")
	testing.expect_value(t, store.writes, 0)
	press_all(&r, .Green, .Down, .Green) // embark
	testing.expect(t, store.has)
	writes := store.writes
	press_all(&r, .Right)
	testing.expect_value(t, store.writes, writes + 1) // a move is a turn
	testing.expect_value(t, string(store.key[:store.key_len]), "tggd-lrj2025:save")
	// abandon removes it at once
	press_all(&r, .Red, .Down, .Green, .Down, .Green)
	testing.expect_value(t, r.core.screen, game.Screen.Main_Menu)
	testing.expect(t, !store.has)
	testing.expect(t, !r.core.has_save)
}

@(test)
dying_removes_the_save_before_the_death_screen :: proc(t: ^testing.T) {
	store_reset()
	r := saving_rig(); defer rig_free(&r)
	press_all(&r, .Green, .Down, .Green) // a real game, saved
	testing.expect(t, store.has)
	c := r.core
	loc := int(c.world.characters[c.world.avatar].location)
	// weaken the player and stand a moon person on a free neighbour, then attack it
	game.stat_set(&c.world.characters[c.world.avatar].stats, .Health, 10)
	attack := game.Command.None
	cmd := [game.Direction]game.Command{.North = .Up, .East = .Right, .South = .Down, .West = .Left}
	for d in game.Direction {
		n := game.location_neighbor(&c.world, loc, d)
		if n != game.NONE && !game.is_solid(c.world.locations[n].location_type) && c.world.locations[n].character == game.NONE {
			game.add_character(&c.world, .Moon_Person, n)
			attack = cmd[d]
			break
		}
	}
	testing.expect(t, attack != .None)
	press_all(&r, attack)
	testing.expect(t, game.is_dead(&c.world, c.world.avatar))
	testing.expect(t, !store.has) // gone while the death messages are still on screen
	testing.expect_value(t, c.screen, game.Screen.Message)
}

@(test)
continue_appears_only_with_a_valid_save_and_resumes_the_same_world :: proc(t: ^testing.T) {
	store_reset()
	first := saving_rig()
	press_all(&first, .Green, .Down, .Green)
	for _ in 0 ..< 30 { press_all(&first, .Right, .Down, .Left, .Up) ; for first.core.screen == .Message { press_all(&first, .Green) } }
	reference := first.core.world
	rig_free(&first)
	testing.expect(t, store.has)

	again := saving_rig(); defer rig_free(&again)
	testing.expect(t, again.core.has_save)
	press_all(&again, .Green) // title -> main menu
	menu := game.menu_of(again.core, .Main_Menu)
	testing.expect_value(t, len(menu.items), 3)
	testing.expect_value(t, menu.items[0], "Continue")
	testing.expect_value(t, press_all(&again, .Green), game.Screen.Navigation)
	testing.expect(t, again.core.world == reference)
}

@(test)
a_pending_message_comes_back_as_the_message_screen :: proc(t: ^testing.T) {
	store_reset()
	first := saving_rig()
	press_all(&first, .Green, .Down, .Green)
	// make the next move produce a message: put a potion under the next tile's feet is overkill; add one directly
	game.add_message(first.core, first.core.world.avatar, .Take, "Hello", "again")
	first.core.screen = .Message
	press_all(&first, .Up) // any command counts as a turn and saves
	rig_free(&first)
	again := saving_rig(); defer rig_free(&again)
	press_all(&again, .Green, .Green)
	testing.expect_value(t, again.core.screen, game.Screen.Message)
	testing.expect_value(t, game.current_message_line(&again.core.world, 0), "Hello")
	testing.expect_value(t, again.core.world.messages[0].sfx, game.Sfx.Take)
}

@(test)
a_damaged_save_is_ignored_whole_and_left_alone :: proc(t: ^testing.T) {
	w := gen(9); defer free(w)
	buf := make([]u8, game.SAVE_BUFFER_SIZE); defer delete(buf)
	good, _ := game.encode_world(w, buf)
	probe := new(game.World); defer free(probe)
	testing.expect(t, game.decode_world(good, probe))

	bad_cases := [?]string{
		"", "garbage", "TGGDLRJ2025-SAVE-2\n16 0 1 2",
		good[:len(good) / 2],            // truncated
		good[:len(good) - 3],            // truncated at the end
	}
	for text in bad_cases { testing.expect(t, !game.decode_world(text, probe)) }

	// single-token damage: replace one number with an out-of-range or malformed one, many places
	text := make([]u8, len(good)); defer delete(text)
	rng: game.Rng
	game.rng_seed(&rng, 99)
	accepted_damaged := 0
	for _ in 0 ..< 400 {
		copy(text, good)
		at := game.rng_range(&rng, len(game.SAVE_HEADER) + 1, len(text) - 1)
		switch game.rng_range(&rng, 0, 2) {
		case 0: text[at] = 'x'
		case 1: text[at] = '9'
		case 2: text[at] = '-'
		}
		// whatever happens, it must not crash; if it is accepted it must still be a fully valid world
		if game.decode_world(string(text), probe) {
			accepted_damaged += 1
			testing.expect(t, game.validate_world(probe))
		}
	}
	testing.expect(t, accepted_damaged < 400) // most damage is caught

	// a save that is damaged at load leaves the game untouched and offers no Continue
	store_reset()
	store_set(game.SAVE_KEY, string(good[:len(good) / 2]))
	r := saving_rig(); defer rig_free(&r)
	testing.expect(t, !r.core.has_save)
	testing.expect_value(t, r.core.world.avatar, game.NONE)
	testing.expect(t, store.has) // not deleted
	press_all(&r, .Green)
	testing.expect_value(t, len(game.menu_of(r.core, .Main_Menu).items), 2)
}

@(test)
semantic_damage_is_caught_not_just_syntax :: proc(t: ^testing.T) {
	w := gen(21); defer free(w)
	probe := new(game.World); defer free(probe)
	buf := make([]u8, game.SAVE_BUFFER_SIZE); defer delete(buf)

	try :: proc(t: ^testing.T, w: ^game.World, buf: []u8, probe: ^game.World, what: string) {
		text, ok := game.encode_world(w, buf)
		testing.expect(t, ok)
		testing.expectf(t, !game.decode_world(text, probe), "accepted a save with %s", what)
	}
	// each case damages a copy of a good world, then saves it as-is (the text is syntactically perfect)
	damage :: proc(w: ^game.World, f: proc(^game.World)) -> ^game.World {
		c := new(game.World)
		c^ = w^
		f(c)
		return c
	}
	c := damage(w, proc(c: ^game.World) { c.avatar = 2 }); try(t, c, buf, probe, "the avatar set to a moon person"); free(c)
	c = damage(w, proc(c: ^game.World) { c.locations[game.location_id(2, 3, 3)].location_type = .Gray_Wall }); try(t, c, buf, probe, "a wall in a room floor"); free(c)
	c = damage(w, proc(c: ^game.World) { c.locations[game.location_id(3, 7, 0)].destination = game.NONE }); try(t, c, buf, probe, "a door with no destination"); free(c)
	c = damage(w, proc(c: ^game.World) { c.characters[c.avatar].location = 7 }); try(t, c, buf, probe, "the avatar not on its tile"); free(c)
	c = damage(w, proc(c: ^game.World) { c.items[0].holder = .Character; c.items[0].holder_id = 63 }); try(t, c, buf, probe, "an item held by nobody"); free(c)
	c = damage(w, proc(c: ^game.World) { c.map_types[5] = .Starting_Room }); try(t, c, buf, probe, "two starting rooms"); free(c)
	c = damage(w, proc(c: ^game.World) { game.stat_set(&c.characters[c.avatar].stats, .Health, 0) }); try(t, c, buf, probe, "a dead avatar"); free(c)
}

@(test)
embarking_over_a_save_replaces_it_and_a_full_storage_does_not_stop_play :: proc(t: ^testing.T) {
	store_reset()
	first := saving_rig()
	press_all(&first, .Green, .Down, .Green)
	rig_free(&first)
	old_len := store.len
	again := saving_rig(); defer rig_free(&again)
	press_all(&again, .Green, .Down, .Down, .Green) // Continue, Tutorial, Embark!: asks first
	testing.expect_value(t, again.core.screen, game.Screen.Confirm_Embark)
	testing.expect_value(t, press_all(&again, .Green), game.Screen.Main_Menu) // No is first
	testing.expect_value(t, again.core.has_save, true)
	press_all(&again, .Down, .Down, .Green, .Red) // ask again, cancel with Red
	testing.expect_value(t, again.core.screen, game.Screen.Main_Menu)
	press_all(&again, .Down, .Down, .Green, .Down, .Green) // ask again, Yes
	testing.expect_value(t, again.core.screen, game.Screen.Navigation)
	testing.expect(t, store.has)
	_ = old_len
	// quota exceeded: play goes on, nothing is stored, and Continue is not offered afterwards
	store_reset()
	store.refuse = true
	r := saving_rig(); defer rig_free(&r)
	testing.expect_value(t, press_all(&r, .Green, .Down, .Green), game.Screen.Navigation)
	press_all(&r, .Right, .Right)
	testing.expect(t, !store.has)
	testing.expect(t, !r.core.has_save)
}
