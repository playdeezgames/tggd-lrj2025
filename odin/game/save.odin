package game

// Saving: the whole world as one line-oriented text of decimal numbers (and hex for message text). Written after every
// turn, read once at start. Loading validates every field and every cross reference, so a damaged or hand-edited save is
// refused whole and never reaches the game (the player just sees no Continue item).
//
// Format: a header line, then, as whitespace-separated tokens:
//   map_count, then one map type per map
//   per location (map_count * 225 of them, in id order): type, character, room_number, destination
//   character_count, then per character: type, location, tags, then per stat: flags [value min max if flags != 0]
//   item_count, then per item: type, holder kind, holder id, then per stat the same way
//   avatar
//   message_count, then per message: has_sfx, sfx, line_count, then per line: length and its bytes in hex ("_" if empty)

SAVE_KEY :: "tggd-lrj2025:save" // namespaced: every HTML5 game on itch.io shares one localStorage origin
SAVE_HEADER :: "TGGDLRJ2025-SAVE-1"
SAVE_BUFFER_SIZE :: 160 * 1024

// ---- writing ---------------------------------------------------------------------------------------
Writer :: struct {
	buf:      []u8,
	n:        int,
	overflow: bool,
}

w_bytes :: proc(w: ^Writer, s: string) {
	if w.n + len(s) > len(w.buf) { w.overflow = true; return }
	copy(w.buf[w.n:], s)
	w.n += len(s)
}

w_byte :: proc(w: ^Writer, b: u8) {
	if w.n >= len(w.buf) { w.overflow = true; return }
	w.buf[w.n] = b
	w.n += 1
}

w_int :: proc(w: ^Writer, value: int) {
	digits: [24]u8
	n := 0
	v := value
	negative := v < 0
	if negative { v = -v }
	for {
		digits[n] = u8('0' + v % 10)
		n += 1
		v /= 10
		if v == 0 { break }
	}
	if negative { w_byte(w, '-') }
	for i := n - 1; i >= 0; i -= 1 { w_byte(w, digits[i]) }
	w_byte(w, ' ')
}

w_stats :: proc(w: ^Writer, stats: ^Stats) {
	for stat in Stat {
		slot := stats[stat]
		w_int(w, int(transmute(u8)slot.flags))
		if slot.flags != {} {
			w_int(w, int(slot.value))
			w_int(w, int(slot.min))
			w_int(w, int(slot.max))
		}
	}
}


// The text of a save for the world, in `buf`; ok is false when it did not fit.
encode_world :: proc(world: ^World, buf: []u8) -> (text: string, ok: bool) {
	w := Writer{buf = buf}
	hex := "0123456789abcdef"
	w_bytes(&w, SAVE_HEADER)
	w_byte(&w, '\n')
	w_int(&w, world.map_count)
	for i in 0 ..< world.map_count { w_int(&w, int(world.map_types[i])) }
	for i in 0 ..< world.map_count * LOCATIONS_PER_MAP {
		loc := &world.locations[i]
		w_int(&w, int(loc.location_type))
		w_int(&w, int(loc.character))
		w_int(&w, int(loc.room_number))
		w_int(&w, int(loc.destination))
	}
	w_byte(&w, '\n')
	w_int(&w, world.character_count)
	for i in 0 ..< world.character_count {
		ch := &world.characters[i]
		w_int(&w, int(ch.character_type))
		w_int(&w, int(ch.location))
		w_int(&w, int(transmute(u8)ch.tags))
		w_stats(&w, &ch.stats)
	}
	w_byte(&w, '\n')
	w_int(&w, world.item_count)
	for i in 0 ..< world.item_count {
		it := &world.items[i]
		w_int(&w, int(it.item_type))
		w_int(&w, int(it.holder))
		w_int(&w, int(it.holder_id))
		w_stats(&w, &it.stats)
	}
	w_byte(&w, '\n')
	w_int(&w, world.avatar)
	w_int(&w, world.message_count)
	for i in 0 ..< world.message_count {
		m := &world.messages[i]
		w_int(&w, 1 if m.has_sfx else 0)
		w_int(&w, int(m.sfx))
		w_int(&w, int(m.line_count))
		for l in 0 ..< int(m.line_count) {
			line := &m.lines[l]
			w_int(&w, int(line.len))
			if line.len == 0 {
				w_bytes(&w, "_ ")
			} else {
				for b in line.text[:line.len] {
					w_byte(&w, hex[b >> 4])
					w_byte(&w, hex[b & 15])
				}
				w_byte(&w, ' ')
			}
		}
	}
	w_byte(&w, '\n')
	return string(buf[:w.n]), !w.overflow
}

// ---- reading ---------------------------------------------------------------------------------------
Reader :: struct {
	text:   string,
	pos:    int,
	failed: bool,
}

r_token :: proc(r: ^Reader) -> string {
	for r.pos < len(r.text) && (r.text[r.pos] == ' ' || r.text[r.pos] == '\n') { r.pos += 1 }
	start := r.pos
	for r.pos < len(r.text) && r.text[r.pos] != ' ' && r.text[r.pos] != '\n' { r.pos += 1 }
	if start == r.pos { r.failed = true }
	return r.text[start:r.pos]
}

// A decimal integer in [lo, hi]; anything else fails the whole read and yields lo.
r_int :: proc(r: ^Reader, lo, hi: int) -> int {
	if r.failed { return lo }
	token := r_token(r)
	if r.failed || len(token) == 0 || len(token) > 10 { r.failed = true; return lo }
	i := 0
	negative := false
	if token[0] == '-' { negative = true; i = 1 }
	if i >= len(token) { r.failed = true; return lo }
	value := 0
	for ; i < len(token); i += 1 {
		c := token[i]
		if c < '0' || c > '9' { r.failed = true; return lo }
		value = value * 10 + int(c - '0')
	}
	if negative { value = -value }
	if value < lo || value > hi { r.failed = true; return lo }
	return value
}

r_stats :: proc(r: ^Reader, stats: ^Stats) {
	for stat in Stat {
		flags := r_int(r, 0, 7)
		stats[stat].flags = transmute(bit_set[Stat_Flag; u8])u8(flags)
		if flags != 0 {
			stats[stat].value = i32(r_int(r, -1_000_000, 1_000_000))
			stats[stat].min = i32(r_int(r, -1_000_000_000, 1_000_000_000))
			stats[stat].max = i32(r_int(r, -1_000_000_000, 1_000_000_000))
		}
	}
}

unhex :: proc(c: u8) -> (value: u8, ok: bool) {
	switch {
	case c >= '0' && c <= '9': return c - '0', true
	case c >= 'a' && c <= 'f': return c - 'a' + 10, true
	}
	return 0, false
}

// Parses a save into `out` (which the caller supplies zeroed or not; it is fully overwritten on success). False on
// any malformation, wrong value or inconsistency; `out` is then unspecified and must be discarded.
decode_world :: proc(text: string, out: ^World) -> bool {
	r := Reader{text = text}
	header_end := 0
	for header_end < len(text) && text[header_end] != '\n' { header_end += 1 }
	if text[:header_end] != SAVE_HEADER { return false }
	r.pos = header_end
	out^ = {}
	world := out

	map_count := r_int(&r, 1, MAX_MAPS)
	if map_count != MAX_MAPS { return false } // every world has exactly the starting room, the ending room and 14 rooms
	world.map_count = map_count
	for i in 0 ..< map_count {
		world.map_types[i] = Map_Type(r_int(&r, 0, len(Map_Type) - 1))
	}
	if r.failed { return false }
	for i in 0 ..< map_count {
		want: Map_Type = .Room
		if i == 0 { want = .Starting_Room } else if i == 1 { want = .Ending_Room }
		if world.map_types[i] != want { return false }
	}
	total_locations := map_count * LOCATIONS_PER_MAP
	for i in 0 ..< total_locations {
		map_id := i / LOCATIONS_PER_MAP
		within := i % LOCATIONS_PER_MAP
		loc := &world.locations[i]
		loc.map_id = u8(map_id)
		loc.column = u8(within % ROOM_SIZE)
		loc.row = u8(within / ROOM_SIZE)
		loc.in_use = true
		loc.location_type = Location_Type(r_int(&r, 0, len(Location_Type) - 1))
		loc.character = i16(r_int(&r, NONE, MAX_CHARACTERS - 1))
		loc.room_number = i16(r_int(&r, 0, 15))
		loc.destination = i16(r_int(&r, NONE, total_locations - 1))
		if r.failed { return false }
	}
	world.character_count = r_int(&r, 1, MAX_CHARACTERS)
	for i in 0 ..< world.character_count {
		ch := &world.characters[i]
		ch.in_use = true
		ch.character_type = Character_Type(r_int(&r, 0, len(Character_Type) - 1))
		ch.location = i16(r_int(&r, 0, total_locations - 1))
		ch.tags = transmute(bit_set[Tag; u8])u8(r_int(&r, 0, 15))
		r_stats(&r, &ch.stats)
	}
	world.item_count = r_int(&r, 0, MAX_ITEMS)
	for i in 0 ..< world.item_count {
		it := &world.items[i]
		it.in_use = true
		it.item_type = Item_Type(r_int(&r, 0, len(Item_Type) - 1))
		it.holder = Holder_Kind(r_int(&r, 0, len(Holder_Kind) - 1))
		it.holder_id = i16(r_int(&r, NONE, total_locations - 1))
		r_stats(&r, &it.stats)
	}
	world.avatar = r_int(&r, 0, MAX_CHARACTERS - 1)
	world.message_count = r_int(&r, 0, MAX_MESSAGES)
	for i in 0 ..< world.message_count {
		m := &world.messages[i]
		m.has_sfx = r_int(&r, 0, 1) == 1
		m.sfx = Sfx(r_int(&r, 0, len(Sfx) - 1))
		m.line_count = u8(r_int(&r, 0, MAX_MESSAGE_LINES))
		for l in 0 ..< int(m.line_count) {
			n := r_int(&r, 0, MESSAGE_TEXT_SIZE)
			token := r_token(&r)
			if r.failed { return false }
			if n == 0 {
				if token != "_" { return false }
			} else {
				if len(token) != n * 2 { return false }
				for b in 0 ..< n {
					hi, ok1 := unhex(token[b * 2])
					lo, ok2 := unhex(token[b * 2 + 1])
					if !ok1 || !ok2 { return false }
					m.lines[l].text[b] = hi << 4 | lo
				}
			}
			m.lines[l].len = u8(n)
		}
	}
	if r.failed { return false }
	// nothing may follow
	for r.pos < len(text) {
		if text[r.pos] != ' ' && text[r.pos] != '\n' { return false }
		r.pos += 1
	}
	return validate_world(world)
}

// Cross references and rules that no single field shows: everything the rules rely on.
validate_world :: proc(world: ^World) -> bool {
	total := world.map_count * LOCATIONS_PER_MAP
	// terrain: each tile is what its map type makes it there, except a locked door that was opened
	for i in 0 ..< total {
		loc := &world.locations[i]
		terrain := terrain_at(world.map_types[loc.map_id], int(loc.column), int(loc.row))
		if loc.location_type != terrain {
			_, locked := key_for_door(terrain)
			if !(locked && loc.location_type == .Ending_Room_Floor) { return false }
		}
		if loc.character != NONE {
			c := int(loc.character)
			if c >= world.character_count { return false }
			ch := &world.characters[c]
			if int(ch.location) != i || is_dead(world, c) || is_solid(loc.location_type) { return false }
		}
		// a door that leads somewhere leads to a floor tile; the four wall-middle doors always lead somewhere
		if loc.destination != NONE {
			if loc.location_type != .Door { return false }
			if is_solid(world.locations[loc.destination].location_type) { return false }
		}
	}
	for map_id in 0 ..< world.map_count {
		for d in Direction {
			door := door_from(d)
			if world.locations[location_id(map_id, door.x, door.y)].destination == NONE { return false }
		}
	}
	// characters: alive ones stand on the tile that knows them; exactly one is the player and it is alive
	players := 0
	for c in 0 ..< world.character_count {
		ch := &world.characters[c]
		if !is_dead(world, c) && int(world.locations[ch.location].character) != c { return false }
		if ch.character_type == .N00b { players += 1 }
	}
	if players != 1 { return false }
	if world.avatar >= world.character_count { return false }
	if world.characters[world.avatar].character_type != .N00b || is_dead(world, world.avatar) { return false }
	// items: a holder that exists
	for i in 0 ..< world.item_count {
		it := &world.items[i]
		switch it.holder {
		case .None:      if it.holder_id != NONE { return false }
		case .Location:  if it.holder_id < 0 || int(it.holder_id) >= total { return false }
		case .Character: if it.holder_id < 0 || int(it.holder_id) >= world.character_count { return false }
		}
	}
	return true
}
