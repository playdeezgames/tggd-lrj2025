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
	fill_all(core, .Black)
	text, small, sprites := &FONTS[.Text], &FONTS[.Small], &FONTS[.Sprites]
	write_centered(core, text, FRAME_WIDTH / 2, 0, .Light_Blue, "Blue Room")
	// the twelve sprites, six to a row, each in its own hue
	for n in 1 ..= 12 {
		write_glyph(core, sprites, ((n - 1) % 6) * 10 + 2, 12 + ((n - 1) / 6) * 11, Hue(n + 2), u8(n))
	}
	write_text(core, small, 0, 36, .Red, "H100 ")
	write_text(core, small, 20, 36, .Magenta, "S100")
	write_centered(core, small, FRAME_WIDTH / 2, 45, .Dark_Gray, "m3x6 + m5x7")
	// 24 swatches, 2 pixels wide
	for hue in 0 ..< len(Hue) {
		fill_rect(core, 8 + hue * 2, 54, 2, 3, Hue(hue))
	}
	// the last colour command, as a bar in its own colour
	#partial switch core.last_command {
	case .Green:  fill_rect(core, 2, 59, 60, 3, .Green)
	case .Red:    fill_rect(core, 2, 59, 60, 3, .Red)
	case .Blue:   fill_rect(core, 2, 59, 60, 3, .Blue)
	case .Yellow: fill_rect(core, 2, 59, 60, 3, .Yellow)
	}
	set_pixel(core, core.cursor_x, core.cursor_y, .White)
}
