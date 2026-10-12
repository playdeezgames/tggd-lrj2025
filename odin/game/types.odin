package game

// The world: flat fixed-size arrays referenced by integer ids, with no pointers, so it can be saved and validated as
// plain data. The original keeps the same shape (WorldData lists referenced by index) behind throwaway wrapper objects.
//
// Every map of this game is 15 by 15, so a location's id is map * LOCATIONS_PER_MAP + column + row * ROOM_SIZE. The
// original's ids are the same, because it creates each map's locations in one go, in map creation order.

ROOM_SIZE :: 15
LOCATIONS_PER_MAP :: ROOM_SIZE * ROOM_SIZE
MAX_MAPS :: 16 // 1 starting room, 14 rooms, 1 ending room
MAX_LOCATIONS :: MAX_MAPS * LOCATIONS_PER_MAP
MAX_CHARACTERS :: 64 // 40 moon people and the player, with room to spare
MAX_ITEMS :: 256

NONE :: -1 // "no character / no location / no holder" in id fields

// Order is the original's DirectionTypes order; it decides who is attacked first in a threat sweep.
Direction :: enum u8 { North, East, South, West }
DIRECTION_DELTA :: [Direction][2]int{.North = {0, -1}, .East = {1, 0}, .South = {0, 1}, .West = {-1, 0}}
DIRECTION_OPPOSITE :: [Direction]Direction{.North = .South, .East = .West, .South = .North, .West = .East}

// Map creation order is the original's MapTypes order (Starting, Ending, then the 14 Rooms).
Map_Type :: enum u8 { Starting_Room, Ending_Room, Room }

Location_Type :: enum u8 {
	Starting_Room_Floor,
	Room_Floor,
	Ending_Room_Floor,
	Blue_Wall,
	Gray_Wall,
	Door,
	Silver_Door,
	Gold_Door,
	Carnelian_Door,
	Amethyst_Door,
	Sapphire_Door,
	Ruby_Door,
	Emerald_Door,
	Final_Sign,
	Sign,
}

Character_Type :: enum u8 { N00b, Moon_Person }

Item_Type :: enum u8 {
	Silver_Key,
	Gold_Key,
	Carnelian_Key,
	Amethyst_Key,
	Sapphire_Key,
	Ruby_Key,
	Emerald_Key,
	Food,
	Sword,
	Shield,
	Potion,
}

// ---- statistics: a value with optional bounds, read back clamped (Entity.GetStatistic) --------------
Stat :: enum u8 { Health, Satiety, Attack, Defend, Sword_Durability, Shield_Durability }

Stat_Flag :: enum u8 { Has_Value, Has_Min, Has_Max }

Stat_Slot :: struct {
	value, min, max: i32,
	flags:           bit_set[Stat_Flag; u8],
}

Stats :: [Stat]Stat_Slot

stat_set :: proc(stats: ^Stats, stat: Stat, value: int) {
	stats[stat].value = i32(value)
	stats[stat].flags += {.Has_Value}
}

stat_set_min :: proc(stats: ^Stats, stat: Stat, value: int) {
	stats[stat].min = i32(value)
	stats[stat].flags += {.Has_Min}
}

stat_set_max :: proc(stats: ^Stats, stat: Stat, value: int) {
	stats[stat].max = i32(value)
	stats[stat].flags += {.Has_Max}
}

stat_has :: proc(stats: ^Stats, stat: Stat) -> bool {
	return .Has_Value in stats[stat].flags
}

// The value clamped to its bounds (0 when never set; callers that care use stat_has).
stat_get :: proc(stats: ^Stats, stat: Stat) -> int {
	slot := stats[stat]
	if .Has_Value not_in slot.flags { return 0 }
	value := int(slot.value)
	if .Has_Min in slot.flags { value = max(value, int(slot.min)) }
	if .Has_Max in slot.flags { value = min(value, int(slot.max)) }
	return value
}

// The original's `Clamp(min, max)` order: when min > max (never in the data) the max wins.
stat_min :: proc(stats: ^Stats, stat: Stat) -> int {
	return int(stats[stat].min) if .Has_Min in stats[stat].flags else int(min(i32)) // Integer.MinValue
}

stat_max :: proc(stats: ^Stats, stat: Stat) -> int {
	return int(stats[stat].max) if .Has_Max in stats[stat].flags else int(max(i32)) // Integer.MaxValue
}

stat_change :: proc(stats: ^Stats, stat: Stat, delta: int) -> int {
	stat_set(stats, stat, stat_get(stats, stat) + delta)
	return stat_get(stats, stat)
}

// ---- entities ---------------------------------------------------------------------------------------
Tag :: enum u8 { Key_Message, Food_Message, Eat_Message, Potion_Message }

Location :: struct {
	location_type: Location_Type,
	map_id:        u8,
	column, row:   u8,
	character:     i16, // character id, or NONE
	room_number:   i16, // the RoomNumber statistic of a room's centre sign (0: none)
	destination:   i16, // the DestinationLocationId statistic of a door (NONE: none)
	in_use:        bool,
}

Character :: struct {
	character_type: Character_Type,
	location:       i16,
	stats:          Stats,
	tags:           bit_set[Tag; u8],
	in_use:         bool,
}

Holder_Kind :: enum u8 { None, Location, Character }

Item :: struct {
	item_type: Item_Type,
	holder:    Holder_Kind,
	holder_id: i16,
	stats:     Stats,
	in_use:    bool,
}

// ---- messages: a FIFO of modal pop-ups the player dismisses one by one (MessageData) --------------------------
MAX_MESSAGES :: 32
MAX_MESSAGE_LINES :: 6
MESSAGE_TEXT_SIZE :: 24

Message_Line :: struct {
	text: [MESSAGE_TEXT_SIZE]u8,
	len:  u8,
}

Message :: struct {
	sfx:        Sfx,
	has_sfx:    bool,
	line_count: u8,
	lines:      [MAX_MESSAGE_LINES]Message_Line,
}

World :: struct {
	map_types:      [MAX_MAPS]Map_Type,
	map_count:      int,
	locations:      [MAX_LOCATIONS]Location,
	characters:     [MAX_CHARACTERS]Character,
	character_count: int,
	items:          [MAX_ITEMS]Item,
	item_count:     int,
	avatar:         int, // character id, or NONE
	messages:       [MAX_MESSAGES]Message,
	message_count:  int,
}
