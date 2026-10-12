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
	// the green bar sits at (2..62, 38..41); the cursor is elsewhere
	testing.expect_value(t, r.out.frame[10 + 39 * game.FRAME_WIDTH], palette[game.Hue.Green])
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
