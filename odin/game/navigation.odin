package game

// The in-play picture (NavigationState.Refresh): the avatar's room centred on the avatar, a stats bar along the top,
// the carried items along the bottom, and carried keys down the right edge.

// The small font's ink is 6 rows (its other two rows are descenders the HUD never uses); the original's 3x5 font was 6 tall.
HUD_BAR_HEIGHT :: 6
SPRITE_SIZE :: 10

draw_navigation :: proc(core: ^Core) {
	world := &core.world
	fill_all(core, .Black)
	draw_map(core, world)
	draw_statistics(core, world)
	draw_keys(core, world)
}

draw_map :: proc(core: ^Core, world: ^World) {
	avatar := &world.locations[world.characters[world.avatar].location]
	map_id := int(avatar.map_id)
	// the integer divisions truncate toward zero, as in the original; the minimum is a negative number
	center_x := (FRAME_WIDTH - SPRITE_SIZE) / 2
	center_y := (FRAME_HEIGHT - SPRITE_SIZE) / 2
	min_column := -((FRAME_WIDTH - SPRITE_SIZE) / 2 + SPRITE_SIZE - 1) / SPRITE_SIZE
	min_row := -((FRAME_HEIGHT - SPRITE_SIZE) / 2 + SPRITE_SIZE - 1) / SPRITE_SIZE
	render_columns := (FRAME_WIDTH + SPRITE_SIZE - 1) / SPRITE_SIZE
	render_rows := (FRAME_HEIGHT + SPRITE_SIZE - 1) / SPRITE_SIZE
	for column in min_column ..< min_column + render_columns {
		for row in min_row ..< min_row + render_rows {
			id := location_at(world, map_id, column + int(avatar.column), row + int(avatar.row))
			if id == NONE { continue }
			draw_location(core, world, id, column * SPRITE_SIZE + center_x, row * SPRITE_SIZE + center_y)
		}
	}
}

draw_sprite :: proc(core: ^Core, x, y: int, display: Display) {
	write_glyph(core, &FONTS[.Sprites], x, y, display.hue, u8(display.sprite))
}

draw_location :: proc(core: ^Core, world: ^World, id, x, y: int) {
	loc := &world.locations[id]
	location_display := LOCATION_DISPLAY
	item_display := ITEM_DISPLAY
	character_display := CHARACTER_DISPLAY
	draw_sprite(core, x, y, location_display[loc.location_type])
	for i in 0 ..< world.item_count { // items on the floor, in creation order
		item := &world.items[i]
		if item.in_use && item.holder == .Location && int(item.holder_id) == id {
			draw_sprite(core, x, y, item_display[item.item_type])
		}
	}
	if !is_solid(loc.location_type) && location_threatens(world, id, world.avatar) {
		draw_sprite(core, x, y, {.Threat, .Dark_Red})
	}
	if loc.character != NONE {
		draw_sprite(core, x, y, character_display[world.characters[loc.character].character_type])
	}
}

// "H" or "S" and a three-digit, zero-padded number, then a space ({x:d3}).
format_readout :: proc(buffer: []u8, letter: u8, value: int) -> string {
	buffer[0] = letter
	v := max(value, 0)
	buffer[1] = u8('0' + (v / 100) % 10)
	buffer[2] = u8('0' + (v / 10) % 10)
	buffer[3] = u8('0' + v % 10)
	buffer[4] = ' '
	return string(buffer[:5])
}

format_count :: proc(buffer: []u8, value: int) -> string {
	n := 0
	digits: [20]u8
	v := max(value, 0)
	for {
		digits[n] = u8('0' + v % 10)
		n += 1
		v /= 10
		if v == 0 { break }
	}
	for i in 0 ..< n { buffer[i] = digits[n - 1 - i] }
	return string(buffer[:n])
}

draw_statistics :: proc(core: ^Core, world: ^World) {
	small := &FONTS[.Small]
	avatar := &world.characters[world.avatar]
	fill_rect(core, 0, 0, FRAME_WIDTH, HUD_BAR_HEIGHT, .Darker_Gray)
	buffer: [8]u8
	x := write_text(core, small, 0, 0, .Red, format_readout(buffer[:], 'H', stat_get(&avatar.stats, .Health)))
	write_text(core, small, x, 0, .Magenta, format_readout(buffer[:], 'S', stat_get(&avatar.stats, .Satiety)))

	y := FRAME_HEIGHT - SPRITE_SIZE
	fill_rect(core, 0, y, FRAME_WIDTH, SPRITE_SIZE, .Darker_Gray)
	item_display := ITEM_DISPLAY
	avatar_id := world.avatar
	x = 0
	x = draw_counted(core, x, y, item_display[.Food], item_type_count(world, .Character, avatar_id, .Food))
	x = draw_counted(core, x, y, item_display[.Potion], item_type_count(world, .Character, avatar_id, .Potion))
	// the sword and shield in use count as one more than the spares in the pack
	swords := item_type_count(world, .Character, avatar_id, .Sword) + (1 if stat_get(&avatar.stats, .Sword_Durability) > 0 else 0)
	x = draw_counted(core, x, y, item_display[.Sword], swords)
	shields := item_type_count(world, .Character, avatar_id, .Shield) + (1 if stat_get(&avatar.stats, .Shield_Durability) > 0 else 0)
	draw_counted(core, x, y, item_display[.Shield], shields)
}

// A sprite with its count written over the top-left corner in white; returns the x past the sprite.
draw_counted :: proc(core: ^Core, x, y: int, display: Display, count: int) -> int {
	buffer: [20]u8
	draw_sprite(core, x, y, display)
	write_text(core, &FONTS[.Small], x, y, .White, format_count(buffer[:], count))
	return x + SPRITE_SIZE
}

draw_keys :: proc(core: ^Core, world: ^World) {
	item_display := ITEM_DISPLAY
	x := FRAME_HEIGHT - SPRITE_SIZE * 5 / 4 // sic: the original names this x but derives it from Rows
	y := 0
	for i in 0 ..< world.item_count {
		item := &world.items[i]
		if item.in_use && item.holder == .Character && int(item.holder_id) == world.avatar && is_key(item.item_type) {
			draw_sprite(core, x, y, item_display[item.item_type])
			y += SPRITE_SIZE / 2
		}
	}
}
