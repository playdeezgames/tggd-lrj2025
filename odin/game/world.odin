package game

// Building and querying the world. (Descriptor behaviour such as spawning rules arrives with world generation.)

world_clear :: proc(world: ^World) {
	world^ = {}
	world.avatar = NONE
}

location_id :: proc(map_id, column, row: int) -> int {
	return map_id * LOCATIONS_PER_MAP + column + row * ROOM_SIZE
}

// The location at a place on a map, or NONE when off the map (the original returns Nothing).
location_at :: proc(world: ^World, map_id, column, row: int) -> int {
	if column < 0 || column >= ROOM_SIZE || row < 0 || row >= ROOM_SIZE { return NONE }
	return location_id(map_id, column, row)
}

location_neighbor :: proc(world: ^World, id: int, direction: Direction) -> int {
	loc := &world.locations[id]
	delta := DIRECTION_DELTA
	d := delta[direction]
	return location_at(world, int(loc.map_id), int(loc.column) + d.x, int(loc.row) + d.y)
}

// Does anyone other than `character` stand next to this location? (Location.Threatens)
location_threatens :: proc(world: ^World, id: int, character: int) -> bool {
	for direction in Direction {
		neighbor := location_neighbor(world, id, direction)
		if neighbor == NONE { continue }
		occupant := int(world.locations[neighbor].character)
		if occupant != NONE && occupant != character { return true }
	}
	return false
}

set_location_type :: proc(world: ^World, id: int, t: Location_Type) {
	world.locations[id].location_type = t
}

// Adds a map with its locations in place and returns its id (the terrain of Starting, Ending and Room maps).
// Starting-room avatar placement is the caller's job (it needs the generator's random numbers).
add_map :: proc(world: ^World, map_type: Map_Type) -> int {
	assert(world.map_count < MAX_MAPS)
	map_id := world.map_count
	world.map_count += 1
	world.map_types[map_id] = map_type
	for row in 0 ..< ROOM_SIZE {
		for column in 0 ..< ROOM_SIZE {
			t := terrain_at(map_type, column, row)
			world.locations[location_id(map_id, column, row)] = {
				location_type = t, map_id = u8(map_id), column = u8(column), row = u8(row),
				character = NONE, destination = NONE, in_use = true,
			}
		}
	}
	return map_id
}

HALF :: ROOM_SIZE / 2

// What each cell of a map is made of (the descriptors' Initialize loops).
terrain_at :: proc(map_type: Map_Type, column, row: int) -> Location_Type {
	switch map_type {
	case .Starting_Room, .Room:
		floor := Location_Type.Starting_Room_Floor if map_type == .Starting_Room else Location_Type.Room_Floor
		if column == 0 || row == 0 || column == ROOM_SIZE - 1 || row == ROOM_SIZE - 1 {
			if column == HALF || row == HALF { return .Door }
			return .Gray_Wall
		}
		if column == HALF && row == HALF { return .Sign }
		return floor
	case .Ending_Room:
		ending := ENDING_ROOM_TERRAIN
		switch ending[row][column] {
		case '.': return .Ending_Room_Floor
		case '#': return .Blue_Wall
		case '+': return .Door
		case '1': return .Silver_Door
		case '2': return .Gold_Door
		case '3': return .Carnelian_Door
		case '4': return .Amethyst_Door
		case '5': return .Sapphire_Door
		case '6': return .Ruby_Door
		case '7': return .Emerald_Door
		case '!': return .Final_Sign
		}
	}
	panic("unknown terrain character")
}

ENDING_ROOM_TERRAIN :: [ROOM_SIZE]string {
	"#######+#######",
	"#.............#",
	"#.###########.#",
	"#.#....3....#.#",
	"#.#.#######.#.#",
	"#.#.#..5..#.#.#",
	"#.#.#.###.#.#.#",
	"+.#2#6#!#.4.#.+",
	"#.#.#.#7#.###.#",
	"#.#.#...#.#.#.#",
	"#.#.#######.#.#",
	"#.#.........#.#",
	"#.#####1#####.#",
	"#.............#",
	"#######+#######",
}

add_character :: proc(world: ^World, t: Character_Type, location: int) -> int {
	assert(world.character_count < MAX_CHARACTERS)
	id := world.character_count
	world.character_count += 1
	world.characters[id] = {character_type = t, location = i16(location), stats = character_initial_stats(t), in_use = true}
	world.locations[location].character = i16(id)
	return id
}

add_item :: proc(world: ^World, t: Item_Type) -> int {
	assert(world.item_count < MAX_ITEMS)
	id := world.item_count
	world.item_count += 1
	world.items[id] = {item_type = t, holder = .None, holder_id = NONE, in_use = true}
	return id
}

// Puts an item on a location or in a character's pack.
give_item :: proc(world: ^World, item: int, kind: Holder_Kind, holder: int) {
	world.items[item].holder = kind
	world.items[item].holder_id = i16(holder)
}

// How many of a type the holder carries (InventoriedEntity.GetItemTypeCount).
item_type_count :: proc(world: ^World, kind: Holder_Kind, holder: int, t: Item_Type) -> int {
	n := 0
	for i in 0 ..< world.item_count {
		item := &world.items[i]
		if item.in_use && item.holder == kind && int(item.holder_id) == holder && item.item_type == t { n += 1 }
	}
	return n
}
