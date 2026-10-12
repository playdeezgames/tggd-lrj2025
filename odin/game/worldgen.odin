package game

// World generation (World.Initialize and WorldInitializer): maps, the maze of doors between rooms, then characters and
// items scattered by each type's spawn rule. The generator's own random numbers drive it, so a seed reproduces a world.

MOON_PERSON_COUNT :: 40
ROOM_COUNT :: 14

// How many of each item type the world gets (the descriptors' ItemCount).
ITEM_COUNT :: [Item_Type]int {
	.Silver_Key = 1, .Gold_Key = 1, .Carnelian_Key = 1, .Amethyst_Key = 1, .Sapphire_Key = 1, .Ruby_Key = 1, .Emerald_Key = 1,
	.Food = 50, .Sword = 10, .Shield = 10, .Potion = 25,
}

CHARACTER_COUNT :: [Character_Type]int{.N00b = 0, .Moon_Person = MOON_PERSON_COUNT}

item_initial_stats :: proc(t: Item_Type) -> Stats {
	s: Stats
	#partial switch t {
	case .Sword:
		stat_set(&s, .Attack, 20)
		stat_set(&s, .Sword_Durability, 5)
	case .Shield:
		stat_set(&s, .Defend, 10)
		stat_set(&s, .Shield_Durability, 5)
	case .Potion:
		stat_set(&s, .Health, 50)
	}
	return s
}

// Where a character may be placed (the CanSpawn of each character descriptor).
can_spawn_character :: proc(world: ^World, t: Character_Type, id: int) -> bool {
	loc := &world.locations[id]
	switch t {
	case .N00b:
		return loc.location_type == .Starting_Room_Floor
	case .Moon_Person:
		if loc.character != NONE || is_solid(loc.location_type) { return false }
		if loc.location_type == .Starting_Room_Floor { return false } // decided: no moon people where the player starts
		// not on the four floor tiles just inside the door of each wall
		c, r := int(loc.column), int(loc.row)
		if c == 1 && r == HALF { return false }
		if c == ROOM_SIZE - 2 && r == HALF { return false }
		if c == HALF && r == 1 { return false }
		if c == HALF && r == ROOM_SIZE - 2 { return false }
		return true
	}
	return false
}

// Where an item may be placed (the CanSpawn of each item descriptor). Keys go only on a room floor where a character
// other than the player already stands, so each key starts hidden under a moon person.
can_spawn_item :: proc(world: ^World, t: Item_Type, id: int) -> bool {
	loc := &world.locations[id]
	if is_solid(loc.location_type) { return false }
	if is_key(t) {
		if loc.location_type != .Room_Floor { return false }
		return loc.character != NONE && int(loc.character) != world.avatar
	}
	return !(loc.character != NONE && int(loc.character) == world.avatar)
}

// RNG.FromEnumerable(maps that have a spawnable place) then FromEnumerable(that map's spawnable places): the map is
// chosen uniformly first, so a room's share does not depend on how many places it has. NONE when nothing qualifies.
Spawn_Test :: struct {
	character: bool,
	c_type:    Character_Type,
	i_type:    Item_Type,
}

spawn_ok :: proc(world: ^World, test: Spawn_Test, id: int) -> bool {
	if test.character { return can_spawn_character(world, test.c_type, id) }
	return can_spawn_item(world, test.i_type, id)
}

pick_spawn_location :: proc(world: ^World, rng: ^Rng, test: Spawn_Test) -> int {
	eligible: [MAX_MAPS]int
	n := 0
	for map_id in 0 ..< world.map_count {
		for i in 0 ..< LOCATIONS_PER_MAP {
			if spawn_ok(world, test, map_id * LOCATIONS_PER_MAP + i) {
				eligible[n] = map_id
				n += 1
				break
			}
		}
	}
	if n == 0 { return NONE }
	map_id := eligible[rng_range(rng, 0, n - 1)]
	places: [LOCATIONS_PER_MAP]int
	count := 0
	for i in 0 ..< LOCATIONS_PER_MAP {
		id := map_id * LOCATIONS_PER_MAP + i
		if spawn_ok(world, test, id) {
			places[count] = id
			count += 1
		}
	}
	return places[rng_range(rng, 0, count - 1)]
}

// Door linking: the door in the wall of `from`, and the floor tile just inside the wall of `to` on the far side.
door_from :: proc(direction: Direction) -> [2]int {
	switch direction {
	case .North: return {HALF, 0}
	case .East:  return {ROOM_SIZE - 1, HALF}
	case .South: return {HALF, ROOM_SIZE - 1}
	case .West:  return {0, HALF}
	}
	return {}
}

door_to :: proc(direction: Direction) -> [2]int {
	switch direction {
	case .North: return {HALF, ROOM_SIZE - 2}
	case .East:  return {1, HALF}
	case .South: return {HALF, 1}
	case .West:  return {ROOM_SIZE - 2, HALF}
	}
	return {}
}

link_maps :: proc(world: ^World, from_map, to_map: int, direction: Direction) {
	from := door_from(direction)
	to := door_to(direction)
	world.locations[location_id(from_map, from.x, from.y)].destination = i16(location_id(to_map, to.x, to.y))
}

// Builds a whole new world. Returns false only if a spawn rule found no place at all (the original would crash);
// the caller then tries again with the generator moved on.
generate_world :: proc(world: ^World, rng: ^Rng) -> bool {
	world_clear(world)

	// maps: the starting room first (it places the avatar), the ending room, then the rooms
	start := add_map(world, .Starting_Room)
	candidates: [LOCATIONS_PER_MAP]int
	count := 0
	for i in 0 ..< LOCATIONS_PER_MAP {
		id := start * LOCATIONS_PER_MAP + i
		if can_spawn_character(world, .N00b, id) {
			candidates[count] = id
			count += 1
		}
	}
	world.avatar = add_character(world, .N00b, candidates[rng_range(rng, 0, count - 1)])
	ending := add_map(world, .Ending_Room)
	rooms: [ROOM_COUNT + 2]int // the maze order: starting room, the 14 rooms, ending room
	rooms[0] = start
	for i in 1 ..= ROOM_COUNT { rooms[i] = add_map(world, .Room) }
	rooms[ROOM_COUNT + 1] = ending

	// the maze
	used: [len(rooms)]bit_set[Direction]
	opposite := DIRECTION_OPPOSITE
	for i in 0 ..< len(rooms) - 1 { // the main path: each room to the next through a door it has not used yet
		world.locations[location_id(rooms[i], HALF, HALF)].room_number = i16(i + 1)
		direction: Direction
		for {
			direction = Direction(rng_range(rng, 0, len(Direction) - 1))
			if direction not_in used[i] { break }
		}
		used[i] += {direction}
		used[i + 1] += {opposite[direction]}
		link_maps(world, rooms[i], rooms[i + 1], direction)
		link_maps(world, rooms[i + 1], rooms[i], opposite[direction])
	}
	for i in 0 ..< len(rooms) { // side paths: every door still unused leads to a random room whose opposite door is free
		for direction in Direction {
			if direction in used[i] { continue }
			used[i] += {direction}
			free: [len(rooms)]int
			n := 0
			for j in 0 ..< len(rooms) {
				if opposite[direction] not_in used[j] {
					free[n] = j
					n += 1
				}
			}
			if n == 0 { return false } // cannot happen (free doors of opposite directions are always equal in number)
			next := free[rng_range(rng, 0, n - 1)]
			used[next] += {opposite[direction]}
			link_maps(world, rooms[i], rooms[next], direction)
			link_maps(world, rooms[next], rooms[i], opposite[direction])
		}
	}

	// characters, then items, each by type in declaration order
	character_counts := CHARACTER_COUNT
	for t in Character_Type {
		for _ in 0 ..< character_counts[t] {
			id := pick_spawn_location(world, rng, {character = true, c_type = t})
			if id == NONE { return false }
			add_character(world, t, id)
		}
	}
	item_counts := ITEM_COUNT
	for t in Item_Type {
		for _ in 0 ..< item_counts[t] {
			id := pick_spawn_location(world, rng, {i_type = t})
			if id == NONE { return false }
			item := add_item(world, t)
			world.items[item].stats = item_initial_stats(t)
			give_item(world, item, .Location, id)
		}
	}
	return true
}
