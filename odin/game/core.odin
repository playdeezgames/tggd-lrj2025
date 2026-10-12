package game

// The portable core. core_init once; core_step once per presented frame.
//
// MILESTONE 3: the screen is the in-play navigation picture of a fixed demo room; commands arrive with the rules.

Core :: struct {
	services: Services,
	rng:      Rng,
	hues:     [FRAME_WIDTH * FRAME_HEIGHT]u8,  // what the game draws: palette indices
	frame:    [FRAME_WIDTH * FRAME_HEIGHT]u32, // hues converted to RGBA
	dirty:    bool,
	world:    World,

	sfx_queue: [SFX_QUEUE_SIZE]Sfx, // played by the platform after the step, in order
	sfx_count: int,
}

core_init :: proc(core: ^Core, services: Services) {
	core.services = services
	seed: u64 = 0x5EED
	if services.entropy != nil { seed = services.entropy() }
	rng_seed(&core.rng, seed)
	debug_show_room(core, .Starting_Room, 7, 7)
}

core_step :: proc(core: ^Core, input: Step_Input, out: ^Step_Output) {
	for event in input.events {
		handle_command(core, event.command)
	}
	if core.dirty {
		draw_navigation(core)
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
	// milestone 3 draws a fixed picture; commands arrive with the rules
	_ = core
	_ = command
}

// Hue indices to RGBA, once per changed frame.
present :: proc(core: ^Core) {
	palette := PALETTE
	for hue, i in core.hues {
		core.frame[i] = palette[Hue(hue)]
	}
}

// QA and tests: replace the world with one map of the given type and the avatar standing at (column, row), with a
// few of everything around: items and a moon person. (The page reaches this with ?room=N&x=N&y=N.)
debug_show_room :: proc(core: ^Core, map_type: Map_Type, x, y: int) {
	world := &core.world
	world_clear(world)
	map_id := add_map(world, map_type)
	column, row := clamp(x, 0, ROOM_SIZE - 1), clamp(y, 0, ROOM_SIZE - 1)
	here := location_id(map_id, column, row)
	world.avatar = add_character(world, .N00b, here)
	around :: [?]struct {
		dx, dy: int,
		item:   Item_Type,
	}{{1, 0, .Food}, {-1, 0, .Sword}, {0, 1, .Shield}, {0, -1, .Potion}}
	for a in around {
		id := location_at(world, map_id, column + a.dx, row + a.dy)
		if id != NONE && !is_solid(world.locations[id].location_type) {
			give_item(world, add_item(world, a.item), .Location, id)
		}
	}
	if id := location_at(world, map_id, column + 2, row); id != NONE && !is_solid(world.locations[id].location_type) {
		add_character(world, .Moon_Person, id)
	}
	// a pack: some keys, food, a potion, a spare sword
	for t in ([?]Item_Type{.Silver_Key, .Gold_Key, .Emerald_Key, .Food, .Food, .Potion, .Sword}) {
		give_item(world, add_item(world, t), .Character, world.avatar)
	}
	stat_set(&world.characters[world.avatar].stats, .Health, 87)
	stat_set(&world.characters[world.avatar].stats, .Satiety, 42)
	stat_set(&world.characters[world.avatar].stats, .Shield_Durability, 3)
	core.dirty = true
}
