package game

// The portable core. core_init once; core_step once per presented frame.
//
// MILESTONE 1: the screen is a smoke test (palette swatches and a cursor that the four direction commands move,
// plus the last colour command), only there to prove the input, drawing and build pipeline. The real states replace it.

Core :: struct {
	services: Services,
	rng:      Rng,
	hues:     [FRAME_WIDTH * FRAME_HEIGHT]u8,  // what the game draws: palette indices
	frame:    [FRAME_WIDTH * FRAME_HEIGHT]u32, // hues converted to RGBA
	dirty:    bool,

	// smoke test state
	cursor_x, cursor_y: int,
	last_command:       Command,

	sfx_queue: [SFX_QUEUE_SIZE]Sfx, // played by the platform after the step, in order
	sfx_count: int,
}

core_init :: proc(core: ^Core, services: Services) {
	core.services = services
	seed: u64 = 0x5EED
	if services.entropy != nil { seed = services.entropy() }
	rng_seed(&core.rng, seed)
	core.cursor_x = FRAME_WIDTH / 2
	core.cursor_y = FRAME_HEIGHT / 2
	core.dirty = true
	draw_smoke(core)
}

core_step :: proc(core: ^Core, input: Step_Input, out: ^Step_Output) {
	for event in input.events {
		handle_command(core, event.command)
	}
	if core.dirty {
		draw_smoke(core)
		present(core)
		core.dirty = false
		out.frame_changed = true
	} else {
		out.frame_changed = false
	}
	out.frame = &core.frame
	out.sfx = core.sfx_queue
	out.sfx_count = core.sfx_count
	core.sfx_count = 0
}

handle_command :: proc(core: ^Core, command: Command) {
	#partial switch command {
	case .Up:    core.cursor_y = max(core.cursor_y - 1, 0)
	case .Down:  core.cursor_y = min(core.cursor_y + 1, FRAME_HEIGHT - 1)
	case .Left:  core.cursor_x = max(core.cursor_x - 1, 0)
	case .Right: core.cursor_x = min(core.cursor_x + 1, FRAME_WIDTH - 1)
	case .None:  return
	}
	#partial switch command { // smoke test: each colour command plays a different sound
	case .Green:  play_sfx(core, .Take)
	case .Red:    play_sfx(core, .Yoink)
	case .Blue:   play_sfx(core, .Eat)
	case .Yellow: play_sfx(core, .Woo_Hoo)
	}
	core.last_command = command
	core.dirty = true
}

// Hue indices to RGBA, once per changed frame.
present :: proc(core: ^Core) {
	palette := PALETTE
	for hue, i in core.hues {
		core.frame[i] = palette[Hue(hue)]
	}
}

draw_smoke :: proc(core: ^Core) {
	fill_rect(core, 0, 0, FRAME_WIDTH, FRAME_HEIGHT, .Black)
	// 24 swatches, 6 across and 4 down, 10 by 8 pixels each
	for hue in 0 ..< len(Hue) {
		fill_rect(core, (hue % 6) * 10 + 2, (hue / 6) * 8 + 2, 10, 8, Hue(hue))
	}
	// the last colour command, as a bar in its own colour
	#partial switch core.last_command {
	case .Green:  fill_rect(core, 2, 38, 60, 4, .Green)
	case .Red:    fill_rect(core, 2, 38, 60, 4, .Red)
	case .Blue:   fill_rect(core, 2, 38, 60, 4, .Blue)
	case .Yellow: fill_rect(core, 2, 38, 60, 4, .Yellow)
	}
	set_pixel(core, core.cursor_x, core.cursor_y, .White)
}
