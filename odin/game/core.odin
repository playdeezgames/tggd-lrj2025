package game

// The portable core. core_init once; core_step once per presented frame.
//
Core :: struct {
	services: Services,
	rng:      Rng,
	hues:     [FRAME_WIDTH * FRAME_HEIGHT]u8,  // what the game draws: palette indices
	frame:    [FRAME_WIDTH * FRAME_HEIGHT]u32, // hues converted to RGBA
	dirty:    bool,
	world:    World,
	screen:   Screen,
	menu_index:    int, // the highlighted item of a menu screen
	tutorial_step: int,
	credits_page:  int,

	has_save:  bool, // a valid save is in storage: the main menu offers Continue
	save_buf:  [SAVE_BUFFER_SIZE]u8,

	sfx_queue: [SFX_QUEUE_SIZE]Sfx, // played by the platform after the step, in order
	sfx_count: int,
}

core_init :: proc(core: ^Core, services: Services) {
	core.services = services
	seed: u64 = 0x5EED
	if services.entropy != nil { seed = services.entropy() }
	rng_seed(&core.rng, seed)
	world_clear(&core.world)
	load_save(core)
	core.screen = .Title
	core.dirty = true
}

core_step :: proc(core: ^Core, input: Step_Input, out: ^Step_Output) {
	processed := false
	for event in input.events {
		if event.command != .None { processed = true }
		handle_command(core, event.command)
	}
	if processed { persist(core) } // every turn is saved
	if core.dirty {
		draw_screen(core)
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

// Reads the save, if any, into the world. A save that does not validate is ignored whole (and left in storage).
load_save :: proc(core: ^Core) {
	if core.services.storage_get == nil { return }
	text, found := core.services.storage_get(SAVE_KEY, context.temp_allocator)
	if !found { return }
	loaded := new(World)
	defer free(loaded)
	if decode_world(text, loaded) {
		core.world = loaded^
		core.has_save = true
	}
}

// After a command: the world in play is stored; a finished or abandoned one is removed (at the moment of death, not
// when the death screen is dismissed).
persist :: proc(core: ^Core) {
	if core.services.storage_set == nil || core.services.storage_remove == nil { return }
	world := &core.world
	if world.avatar == NONE || is_dead(world, world.avatar) {
		core.services.storage_remove(SAVE_KEY)
		core.has_save = false
		return
	}
	text, ok := encode_world(world, core.save_buf[:])
	if !ok {
		if core.services.log != nil { core.services.log("save: world did not fit the buffer") }
		return
	}
	core.has_save = core.services.storage_set(SAVE_KEY, text)
	if !core.has_save && core.services.log != nil { core.services.log("save: storage refused the write") }
}

// Generates a fresh world (the Embark menu item). Retries with the generator moved on in the one case the original would
// crash; gives up with a panic after many tries, which would mean a bug.
new_game :: proc(core: ^Core) {
	for _ in 0 ..< 100 {
		if generate_world(&core.world, &core.rng) {
			core.dirty = true
			return
		}
	}
	panic("world generation failed 100 times")
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
	core.screen = .Navigation
	core.dirty = true
}
