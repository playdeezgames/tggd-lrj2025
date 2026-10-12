package game

// The rules: moving, bumping, fighting, hunger, picking things up, using things. A port of Character.vb, the character,
// item and location descriptors' behaviour. Everything that happens is an effect on `core`: the world, queued sounds
// and queued messages. Moon people never move; they only strike back.

import "core:fmt"

CHARACTER_NAMES :: [Character_Type]string{.N00b = "N00b", .Moon_Person = "Moonie"}
HIT_SFX :: [Character_Type]Sfx{.N00b = .Player_Hit, .Moon_Person = .Enemy_Hit}
MISS_SFX :: [Character_Type]Sfx{.N00b = .Player_Miss, .Moon_Person = .Enemy_Miss}
DEATH_SFX :: [Character_Type]Sfx{.N00b = .Player_Death, .Moon_Person = .Enemy_Death}

ITEM_NAMES :: [Item_Type]string {
	.Silver_Key = "Key", .Gold_Key = "Key", .Carnelian_Key = "Key", .Amethyst_Key = "Key", .Sapphire_Key = "Key",
	.Ruby_Key = "Key", .Emerald_Key = "Key", .Food = "Blueberry", .Sword = "Sword", .Shield = "Shield", .Potion = "Potion",
}

PICKUP_SFX :: [Item_Type]Sfx {
	.Silver_Key = .Yoink, .Gold_Key = .Yoink, .Carnelian_Key = .Yoink, .Amethyst_Key = .Yoink, .Sapphire_Key = .Yoink,
	.Ruby_Key = .Yoink, .Emerald_Key = .Yoink, .Food = .Take, .Sword = .Yoink, .Shield = .Yoink, .Potion = .Yoink,
}

FOOD_SATIETY_BENEFIT :: 25

// The key that opens each locked door, and what the door becomes.
key_for_door :: proc(t: Location_Type) -> (key: Item_Type, ok: bool) {
	#partial switch t {
	case .Silver_Door:    return .Silver_Key, true
	case .Gold_Door:      return .Gold_Key, true
	case .Carnelian_Door: return .Carnelian_Key, true
	case .Amethyst_Door:  return .Amethyst_Key, true
	case .Sapphire_Door:  return .Sapphire_Key, true
	case .Ruby_Door:      return .Ruby_Key, true
	case .Emerald_Door:   return .Emerald_Key, true
	}
	return {}, false
}

// ---- messages -----------------------------------------------------------------------------------------
// Character.AddMessage: only the avatar is told anything. Lines longer than a line's capacity are cut.
add_message :: proc(core: ^Core, character: int, sfx: Maybe(Sfx), lines: ..string) {
	world := &core.world
	if character != world.avatar || world.message_count >= MAX_MESSAGES { return }
	m := &world.messages[world.message_count]
	world.message_count += 1
	m^ = {}
	if s, ok := sfx.?; ok {
		m.sfx = s
		m.has_sfx = true
	}
	for line in lines {
		if int(m.line_count) >= MAX_MESSAGE_LINES { break }
		l := &m.lines[m.line_count]
		n := min(len(line), MESSAGE_TEXT_SIZE)
		copy(l.text[:n], line[:n])
		l.len = u8(n)
		m.line_count += 1
	}
}

// The front message's i-th line.
current_message_line :: proc(world: ^World, i: int) -> string {
	l := &world.messages[0].lines[i]
	return string(l.text[:l.len])
}

has_messages :: proc(world: ^World) -> bool { return world.message_count > 0 }

dismiss_message :: proc(world: ^World) {
	if world.message_count == 0 { return }
	for i in 1 ..< world.message_count { world.messages[i - 1] = world.messages[i] }
	world.message_count -= 1
	world.messages[world.message_count] = {}
}

// ---- characters ---------------------------------------------------------------------------------------
is_dead :: proc(world: ^World, c: int) -> bool {
	stats := &world.characters[c].stats
	return stat_get(stats, .Health) == stat_min(stats, .Health)
}

move_character_to :: proc(world: ^World, c, location: int) {
	world.locations[world.characters[c].location].character = NONE
	world.locations[location].character = i16(c)
	world.characters[c].location = i16(location)
}

// The lowest-id item of a type that a holder has (the original's set order is insertion order, near enough), or NONE.
first_item_of_type :: proc(world: ^World, kind: Holder_Kind, holder: int, t: Item_Type) -> int {
	for i in 0 ..< world.item_count {
		item := &world.items[i]
		if item.in_use && item.holder == kind && int(item.holder_id) == holder && item.item_type == t { return i }
	}
	return NONE
}

remove_item :: proc(world: ^World, item: int) {
	world.items[item].holder = .None
	world.items[item].holder_id = NONE
}

// ---- moving -------------------------------------------------------------------------------------------
attempt_move :: proc(core: ^Core, c: int, direction: Direction) {
	world := &core.world
	here := int(world.characters[c].location)
	loc := &world.locations[here]
	delta := DIRECTION_DELTA
	d := delta[direction]
	next := location_at(world, int(loc.map_id), int(loc.column) + d.x, int(loc.row) + d.y)
	if next == NONE { return }
	occupant := int(world.locations[next].character)
	if occupant != NONE {
		interact(core, c, occupant, false)
	} else if !is_solid(world.locations[next].location_type) {
		handle_threats(core, c, here)
		move_character_to(world, c, next)
		on_move(core, c)
	} else {
		handle_threats(core, c, here)
		bump(core, next, c)
		on_move(core, c)
	}
	core.dirty = true
}

// Anyone next to the place being left gets a free strike (Character.HandleThreats); stops if the mover dies.
handle_threats :: proc(core: ^Core, c, location: int) {
	world := &core.world
	if !location_threatens(world, location, c) { return }
	for direction in Direction {
		neighbor := location_neighbor(world, location, direction)
		if neighbor == NONE { continue }
		occupant := int(world.locations[neighbor].character)
		if occupant != NONE {
			interact(core, occupant, c, true)
			if is_dead(world, c) { return }
		}
	}
}

// What a location does when walked into and not entered (the descriptors' Bump).
bump :: proc(core: ^Core, location: int, c: int) {
	world := &core.world
	loc := &world.locations[location]
	#partial switch loc.location_type {
	case .Door:
		// through the door: no check on who stands at the far side (spawning keeps moon people off those tiles)
		if loc.destination != NONE { move_character_to(world, c, int(loc.destination)) }
	case .Silver_Door, .Gold_Door, .Carnelian_Door, .Amethyst_Door, .Sapphire_Door, .Ruby_Door, .Emerald_Door:
		key, _ := key_for_door(loc.location_type)
		item := first_item_of_type(world, .Character, c, key)
		if item != NONE {
			remove_item(world, item)
			loc.location_type = .Ending_Room_Floor
			play_sfx(core, .Woo_Hoo)
		} else {
			play_sfx(core, .Shucks)
		}
	case .Sign:
		add_message(core, c, nil, fmt.tprintf("Room#%d", loc.room_number))
	case .Final_Sign:
		add_message(core, c, nil, "Have you", "checked", "yer", "butthole?")
	}
}

// Character descriptors' OnMove: the player gets hungrier, then collects what is underfoot. Moon people do neither.
on_move :: proc(core: ^Core, c: int) {
	world := &core.world
	ch := &world.characters[c]
	if ch.character_type != .N00b { return }
	if stat_get(&ch.stats, .Satiety) <= stat_min(&ch.stats, .Satiety) {
		food := first_item_of_type(world, .Character, c, .Food)
		if food != NONE {
			play_sfx(core, .Eat)
			use_item(core, food, c)
		} else {
			stat_change(&ch.stats, .Health, -1)
		}
	} else {
		stat_change(&ch.stats, .Satiety, -1)
	}
	here := int(ch.location)
	pickups: [16]int
	n := 0
	for i in 0 ..< world.item_count {
		item := &world.items[i]
		if item.in_use && item.holder == .Location && int(item.holder_id) == here && n < len(pickups) {
			pickups[n] = i
			n += 1
		}
	}
	pickup_sfx := PICKUP_SFX
	for item in pickups[:n] {
		play_sfx(core, pickup_sfx[world.items[item].item_type])
		give_item(world, item, .Character, c)
		take_item(core, item, c)
	}
}

// ---- items --------------------------------------------------------------------------------------------
// ItemTypeDescriptor.OnTake: a one-time hint for the first of a kind, and a sword or shield is put to use at once when
// the player has none in use, otherwise it stays in the pack as a spare.
take_item :: proc(core: ^Core, item, c: int) {
	world := &core.world
	ch := &world.characters[c]
	it := &world.items[item]
	switch it.item_type {
	case .Silver_Key, .Gold_Key, .Carnelian_Key, .Amethyst_Key, .Sapphire_Key, .Ruby_Key, .Emerald_Key:
		if .Key_Message not_in ch.tags {
			ch.tags += {.Key_Message}
			add_message(core, c, nil, "Save keys", "to open", "doors")
		}
	case .Food:
		if .Food_Message not_in ch.tags {
			ch.tags += {.Food_Message}
			add_message(core, c, nil, "Blueberry", "(fer when", "yer", "hungry!)")
		}
	case .Sword:
		if stat_get(&ch.stats, .Sword_Durability) <= stat_min(&ch.stats, .Sword_Durability) {
			stat_set(&ch.stats, .Sword_Durability, stat_get(&it.stats, .Sword_Durability))
			remove_item(world, item)
			stat_set(&ch.stats, .Attack, stat_get(&it.stats, .Attack))
			add_message(core, c, nil, "You got", "a sword!")
		} else {
			add_message(core, c, nil, "Good to", "have a", "back-up!")
		}
	case .Shield:
		if stat_get(&ch.stats, .Shield_Durability) <= stat_min(&ch.stats, .Shield_Durability) {
			stat_set(&ch.stats, .Shield_Durability, stat_get(&it.stats, .Shield_Durability))
			remove_item(world, item)
			stat_set(&ch.stats, .Defend, stat_get(&it.stats, .Defend))
			add_message(core, c, nil, "You got", "a shield!")
		} else {
			add_message(core, c, nil, "Good to", "have a", "back-up!")
		}
	case .Potion:
		if .Potion_Message not_in ch.tags {
			ch.tags += {.Potion_Message}
			add_message(core, c, nil, "<space>", "to drink", "potion.")
		}
	}
}

// ItemTypeDescriptor.OnUse.
use_item :: proc(core: ^Core, item, c: int) {
	world := &core.world
	ch := &world.characters[c]
	it := &world.items[item]
	#partial switch it.item_type {
	case .Silver_Key, .Gold_Key, .Carnelian_Key, .Amethyst_Key, .Sapphire_Key, .Ruby_Key, .Emerald_Key:
		remove_item(world, item)
	case .Food:
		stat_change(&ch.stats, .Satiety, FOOD_SATIETY_BENEFIT)
		remove_item(world, item)
		if .Eat_Message not_in ch.tags {
			ch.tags += {.Eat_Message}
			add_message(core, c, nil, "Hungry?", "Blueberries", "satisfy!")
		}
	case .Potion:
		benefit := stat_get(&it.stats, .Health)
		stat_change(&ch.stats, .Health, benefit)
		add_message(core, c, nil,
			fmt.tprintf("+%d health", benefit), "you have",
			fmt.tprintf("%d/%d", stat_get(&ch.stats, .Health), stat_max(&ch.stats, .Health)))
		remove_item(world, item)
	}
}

// Character.AttemptUseItemOfType (the potion key): the player drinks one if there is one, then anyone adjacent strikes.
attempt_use_item_of_type :: proc(core: ^Core, c: int, t: Item_Type) {
	world := &core.world
	if world.characters[c].character_type == .N00b {
		item := first_item_of_type(world, .Character, c, t)
		if item == NONE {
			names := ITEM_NAMES
			add_message(core, c, nil, "You have", fmt.tprintf("no %s", names[t]))
		} else {
			use_item(core, item, c)
		}
	}
	handle_threats(core, c, int(world.characters[c].location))
	core.dirty = true
}

// ---- fighting -----------------------------------------------------------------------------------------
// CharacterTypeDescriptor.OnInteract: `agent` strikes `target`; a surviving target strikes back once unless this
// already is a counter-strike.
interact :: proc(core: ^Core, agent, target: int, is_counter: bool) {
	world := &core.world
	if is_dead(world, target) { return }
	names, hit_sfx, miss_sfx, death_sfx := CHARACTER_NAMES, HIT_SFX, MISS_SFX, DEATH_SFX
	a, tg := &world.characters[agent], &world.characters[target]
	attack := stat_get(&a.stats, .Attack)
	defend := stat_get(&tg.stats, .Defend)
	damage := attack - defend
	agent_name := names[a.character_type]
	target_name := names[tg.character_type]
	hit := false
	if damage > 0 {
		sfx := hit_sfx[tg.character_type]
		stat_change(&tg.stats, .Health, -damage)
		if !is_dead(world, target) {
			message := [?]string{agent_name, "hits", fmt.tprintf("for %d!", damage), fmt.tprintf("%d left!", stat_get(&tg.stats, .Health))}
			add_message(core, agent, sfx, ..message[:])
			add_message(core, target, sfx, ..message[:])
		} else {
			message := [?]string{agent_name, "hits", fmt.tprintf("for %d!", damage)}
			add_message(core, agent, sfx, ..message[:])
			add_message(core, target, sfx, ..message[:])
		}
		hit = true
	} else {
		sfx := miss_sfx[a.character_type]
		line := fmt.tprintf("%s misses!", agent_name)
		add_message(core, agent, sfx, line)
		add_message(core, target, sfx, line)
	}
	if hit {
		on_hit_enemy(core, agent)
		on_hit_by_enemy(core, target)
	}
	if is_dead(world, target) {
		// its belongings drop where it fell, and it leaves the tile
		here := int(tg.location)
		for i in 0 ..< world.item_count {
			item := &world.items[i]
			if item.in_use && item.holder == .Character && int(item.holder_id) == target { give_item(world, i, .Location, here) }
		}
		world.locations[here].character = NONE
		sfx := death_sfx[tg.character_type]
		message := [?]string{agent_name, "kills", fmt.tprintf("%s!", target_name)}
		add_message(core, target, sfx, ..message[:])
		add_message(core, agent, sfx, ..message[:])
	} else if !is_counter {
		interact(core, target, agent, true)
	}
}

// Wear on the attacker's sword; at zero the next spare takes over, or the bare-handed attack returns.
on_hit_enemy :: proc(core: ^Core, c: int) {
	world := &core.world
	ch := &world.characters[c]
	if stat_get(&ch.stats, .Sword_Durability) <= stat_min(&ch.stats, .Sword_Durability) { return }
	stat_change(&ch.stats, .Sword_Durability, -1)
	if stat_get(&ch.stats, .Sword_Durability) > stat_min(&ch.stats, .Sword_Durability) { return }
	spares := item_type_count(world, .Character, c, .Sword)
	if spares > 0 {
		item := first_item_of_type(world, .Character, c, .Sword)
		stat_set(&ch.stats, .Sword_Durability, stat_get(&world.items[item].stats, .Sword_Durability))
		remove_item(world, item)
		add_message(core, c, nil, "Yer sword", "broke!", "Equipping", "next one!", fmt.tprintf("(%d left)", spares - 1))
	} else {
		base := character_initial_stats(ch.character_type)
		stat_set(&ch.stats, .Attack, stat_get(&base, .Attack))
		add_message(core, c, nil, "Yer last", "sword", "broke!")
	}
}

// Wear on the defender's shield, the same way.
on_hit_by_enemy :: proc(core: ^Core, c: int) {
	world := &core.world
	ch := &world.characters[c]
	if stat_get(&ch.stats, .Shield_Durability) <= stat_min(&ch.stats, .Shield_Durability) { return }
	stat_change(&ch.stats, .Shield_Durability, -1)
	if stat_get(&ch.stats, .Shield_Durability) > stat_min(&ch.stats, .Shield_Durability) { return }
	spares := item_type_count(world, .Character, c, .Shield)
	if spares > 0 {
		item := first_item_of_type(world, .Character, c, .Shield)
		stat_set(&ch.stats, .Shield_Durability, stat_get(&world.items[item].stats, .Shield_Durability))
		remove_item(world, item)
		add_message(core, c, nil, "Yer shield", "broke!", "Equipping", "next one!", fmt.tprintf("(%d left)", spares - 1))
	} else {
		base := character_initial_stats(ch.character_type)
		stat_set(&ch.stats, .Defend, stat_get(&base, .Defend))
		add_message(core, c, nil, "Yer last", "shield", "broke!")
	}
}
