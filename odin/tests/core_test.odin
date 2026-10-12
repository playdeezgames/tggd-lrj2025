#+build !js
package tests

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
direction_commands_move_the_cursor_and_clamp_at_the_edges :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	x, y := r.core.cursor_x, r.core.cursor_y
	play(&r, .Right, .Down)
	testing.expect_value(t, r.core.cursor_x, x + 1)
	testing.expect_value(t, r.core.cursor_y, y + 1)
	for _ in 0 ..< 100 { play(&r, .Left, .Up) }
	testing.expect_value(t, r.core.cursor_x, 0)
	testing.expect_value(t, r.core.cursor_y, 0)
}

@(test)
a_changed_frame_is_rgba_of_the_drawn_hues :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	play(&r, .Green)
	testing.expect(t, r.out.frame_changed)
	palette := game.PALETTE
	// the green bar sits at (2..62, 59..61); the cursor is elsewhere
	testing.expect_value(t, r.out.frame[10 + 60 * game.FRAME_WIDTH], palette[game.Hue.Green])
	// the cursor is white
	c := r.core
	testing.expect_value(t, r.out.frame[c.cursor_x + c.cursor_y * game.FRAME_WIDTH], palette[game.Hue.White])
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
a_command_queues_its_sound_once_and_the_queue_clears :: proc(t: ^testing.T) {
	r := rig_new(); defer rig_free(&r)
	play(&r, .Green)
	testing.expect_value(t, r.out.sfx_count, 1)
	testing.expect_value(t, r.out.sfx[0], game.Sfx.Take)
	game.core_step(r.core, {}, &r.out)
	testing.expect_value(t, r.out.sfx_count, 0)
}

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
