package game

// The screens (IUIState and its implementations) as one enum plus a command handler and a drawing proc per screen.
// One command in, one transition out, then the screen is redrawn: there is no real-time behaviour.

Screen :: enum u8 {
	Title,
	Main_Menu,
	Tutorial,
	Navigation,
	Message,
	Dead,
	Game_Menu,
	Confirm_Abandon,
	Confirm_Potion,
	Confirm_Embark, // only when a saved game would be replaced
	Credits,
}

// ---- menus (PickerState) -------------------------------------------------------------------------------
Menu :: struct {
	font:      Font_Id,
	hue:       Hue,
	items:     []string,
	caption:   string, // a confirm screen's question; empty for plain menus
	caption_hue: Hue,
}

MAIN_MENU_ITEMS := [?]string{"Tutorial", "Embark!", "Credits"}
MAIN_MENU_ITEMS_WITH_SAVE := [?]string{"Continue", "Tutorial", "Embark!", "Credits"}
GAME_MENU_ITEMS := [?]string{"Continue", "Abandon"}
CONFIRM_ITEMS := [?]string{"No", "Yes"}

menu_of :: proc(core: ^Core, screen: Screen) -> Menu {
	#partial switch screen {
	case .Main_Menu:
		if core.has_save { return {font = .Text, hue = .Light_Gray, items = MAIN_MENU_ITEMS_WITH_SAVE[:]} }
		return {font = .Text, hue = .Light_Gray, items = MAIN_MENU_ITEMS[:]}
	case .Game_Menu:       return {font = .Text, hue = .Cyan, items = GAME_MENU_ITEMS[:]}
	case .Confirm_Abandon: return {font = .Text, hue = .Light_Gray, items = CONFIRM_ITEMS[:], caption = "Abandon?", caption_hue = .Red}
	case .Confirm_Embark:  return {font = .Text, hue = .Light_Gray, items = CONFIRM_ITEMS[:], caption = "Lose save?", caption_hue = .Red}
	case .Confirm_Potion:  return {font = .Small, hue = .Light_Gray, items = CONFIRM_ITEMS[:], caption = "Use Potion?", caption_hue = .Yellow}
	}
	return {}
}

is_menu :: proc(screen: Screen) -> bool {
	#partial switch screen {
	case .Main_Menu, .Game_Menu, .Confirm_Abandon, .Confirm_Potion, .Confirm_Embark: return true
	}
	return false
}

// ---- the tutorial (TutorialState): each step waits for one particular command --------------------------
Tutorial_Step :: struct {
	text:    []string,
	command: Command,
}

TUTORIAL_STEPS := [?]Tutorial_Step {
	{{"<W>, <Z>", "<UpArrow>", "go up!"}, .Up},
	{{"<S>", "<Down", "Arrow>", "go down!"}, .Down},
	{{"<Q>, <A>", "<Left", "Arrow>", "go left!"}, .Left},
	{{"<D>", "<Right", "Arrow>", "go right!"}, .Right},
	{{"<Space>", "action!"}, .Green},
	{{"<Back", "Space>", "cancel!"}, .Red},
}

// ---- credits: pages of short centred lines; the first line of a page is its heading ----------------------
CREDITS_PAGES := [?][]string {
	{"Game by", "TheGrumpy", "GameDev", "lowrezjam", "2025"},
	{"Fonts", "m3x6, m5x7", "by Daniel", "Linssen"},
	{"Sprites", "by VEXED", "Bit Bonanza", "Bountiful", "Bits"},
	{"Sounds", "by", "TheGrumpy", "GameDev"},
}

// ---- transitions ---------------------------------------------------------------------------------------
enter :: proc(core: ^Core, screen: Screen) {
	core.screen = screen
	core.menu_index = 0
	core.dirty = true
}

// Neutral.DetermineState: pending messages first, then death, otherwise play.
enter_neutral :: proc(core: ^Core) {
	switch {
	case has_messages(&core.world):
		enter(core, .Message)
		if m := &core.world.messages[0]; m.has_sfx { play_sfx(core, m.sfx) } // once, when the message appears
	case is_dead(&core.world, core.world.avatar): enter(core, .Dead)
	case:                                         enter(core, .Navigation)
	}
}

abandon :: proc(core: ^Core) {
	world_clear(&core.world)
	enter(core, .Main_Menu)
}

handle_command :: proc(core: ^Core, command: Command) {
	if command == .None { return }
	core.dirty = true
	avatar := core.world.avatar
	switch core.screen {
	case .Title:
		if command == .Green { enter(core, .Main_Menu) }
	case .Main_Menu:
		if menu_navigate(core, command) { break }
		if command == .Green {
			item := menu_of(core, .Main_Menu).items[core.menu_index]
			switch item {
			case "Continue":
				enter_neutral(core)
			case "Tutorial":
				enter(core, .Tutorial)
				core.tutorial_step = 0
			case "Credits":
				enter(core, .Credits)
				core.credits_page = 0
			case "Embark!":
				if core.has_save {
					enter(core, .Confirm_Embark) // a saved game would be lost
				} else {
					new_game(core)
					enter_neutral(core)
				}
			}
		}
	case .Tutorial:
		if command == TUTORIAL_STEPS[core.tutorial_step].command {
			core.tutorial_step += 1
			if core.tutorial_step >= len(TUTORIAL_STEPS) { enter(core, .Main_Menu) }
		}
	case .Navigation:
		#partial switch command {
		case .Up:    attempt_move(core, avatar, .North); enter_neutral(core)
		case .Down:  attempt_move(core, avatar, .South); enter_neutral(core)
		case .Left:  attempt_move(core, avatar, .West); enter_neutral(core)
		case .Right: attempt_move(core, avatar, .East); enter_neutral(core)
		case .Red:   enter(core, .Game_Menu)
		case .Green:
			if first_item_of_type(&core.world, .Character, avatar, .Potion) == NONE {
				attempt_use_item_of_type(core, avatar, .Potion) // "You have no Potion"
				enter_neutral(core)
			} else {
				enter(core, .Confirm_Potion)
			}
		}
	case .Message:
		if command == .Green {
			dismiss_message(&core.world)
			enter_neutral(core)
		}
	case .Dead:
		if command == .Green { abandon(core) }
	case .Game_Menu:
		if menu_navigate(core, command) { break }
		#partial switch command {
		case .Red: enter_neutral(core)
		case .Green:
			if core.menu_index == 0 { enter_neutral(core) } else { enter(core, .Confirm_Abandon) } // Continue / Abandon
		}
	case .Confirm_Abandon:
		if menu_navigate(core, command) { break }
		#partial switch command {
		case .Red: enter(core, .Game_Menu)
		case .Green:
			if core.menu_index == 1 { abandon(core) } else { enter(core, .Game_Menu) } // Yes / No
		}
	case .Credits:
		#partial switch command {
		case .Green:
			core.credits_page += 1
			if core.credits_page >= len(CREDITS_PAGES) { enter(core, .Main_Menu) }
		case .Red: enter(core, .Main_Menu)
		}
	case .Confirm_Embark:
		if menu_navigate(core, command) { break }
		#partial switch command {
		case .Red: enter(core, .Main_Menu)
		case .Green:
			if core.menu_index == 1 {
				new_game(core)
				enter_neutral(core)
			} else {
				enter(core, .Main_Menu)
			}
		}
	case .Confirm_Potion:
		if menu_navigate(core, command) { break }
		#partial switch command {
		case .Red: enter_neutral(core)
		case .Green:
			if core.menu_index == 1 { attempt_use_item_of_type(core, avatar, .Potion) }
			enter_neutral(core)
		}
	}
}

// Up and Down move the highlight with wrap-around. Returns true when the command was one of them.
menu_navigate :: proc(core: ^Core, command: Command) -> bool {
	count := len(menu_of(core, core.screen).items)
	#partial switch command {
	case .Up:
		core.menu_index = (core.menu_index + count - 1) % count
		return true
	case .Down:
		core.menu_index = (core.menu_index + 1) % count
		return true
	}
	return false
}

// ---- drawing -------------------------------------------------------------------------------------------
draw_screen :: proc(core: ^Core) {
	switch core.screen {
	case .Title:      draw_title(core)
	case .Main_Menu, .Game_Menu, .Confirm_Abandon, .Confirm_Potion, .Confirm_Embark: draw_menu(core)
	case .Tutorial:   draw_tutorial(core)
	case .Credits:    draw_credits(core)
	case .Navigation: draw_navigation(core)
	case .Message:    draw_message(core)
	case .Dead:       draw_dead(core)
	}
}

HALF_WIDTH :: FRAME_WIDTH / 2

draw_title :: proc(core: ^Core) {
	fill_all(core, .Black)
	text, small := &FONTS[.Text], &FONTS[.Small]
	lines := [?]string{"The", "Blue", "Room", "of", "SPLORR!!"}
	for line, i in lines { // a shadow one pixel right and down, then the title
		write_centered(core, text, HALF_WIDTH + 1, 1 + i * 8, .Blue, line)
	}
	for line, i in lines {
		write_centered(core, text, HALF_WIDTH, i * 8, .Light_Blue, line)
	}
	y := FRAME_HEIGHT - small.height * 3
	write_centered(core, small, HALF_WIDTH, y, .Dark_Gray, "lowrezjam-2025")
	y += small.height
	write_centered_fitted(core, small, HALF_WIDTH, y, .Dark_Gray, "TheGrumpyGameDev", FRAME_WIDTH)
	y += small.height
	fill_rect(core, 0, y, FRAME_WIDTH, small.height, .Light_Gray)
	write_centered(core, small, HALF_WIDTH, y, .Black, "<space>")
	write_glyph(core, &FONTS[.Sprites], 0, 0, .Brown, u8(Sprite.Player))
}

draw_menu :: proc(core: ^Core) {
	menu := menu_of(core, core.screen)
	font := &FONTS[menu.font]
	fill_all(core, .Black)
	y := FRAME_HEIGHT / 2 - font.height / 2 - font.height * core.menu_index // the highlighted item sits mid-screen
	for item, i in menu.items {
		if i == core.menu_index {
			fill_rect(core, 0, y, FRAME_WIDTH, font.height, menu.hue)
			write_centered(core, font, HALF_WIDTH, y, .Black, item)
		} else {
			write_centered(core, font, HALF_WIDTH, y, menu.hue, item)
		}
		y += font.height
	}
	if menu.caption != "" {
		write_centered(core, font, HALF_WIDTH, 0, menu.caption_hue, menu.caption)
	}
}

draw_tutorial :: proc(core: ^Core) {
	fill_all(core, .Black)
	font := &FONTS[.Text]
	lines := TUTORIAL_STEPS[core.tutorial_step].text
	y := (FRAME_HEIGHT - len(lines) * font.height) / 2
	for line in lines {
		write_centered(core, font, HALF_WIDTH, y, .White, line)
		y += font.height
	}
}

draw_message :: proc(core: ^Core) {
	fill_all(core, .Black)
	font := &FONTS[.Text]
	m := &core.world.messages[0]
	y := (FRAME_HEIGHT - int(m.line_count) * font.height) / 2
	for i in 0 ..< int(m.line_count) {
		write_centered(core, font, HALF_WIDTH, y, .Light_Gray, current_message_line(&core.world, i))
		y += font.height
	}
}

draw_dead :: proc(core: ^Core) {
	fill_all(core, .Black)
	font := &FONTS[.Text]
	write_centered(core, font, HALF_WIDTH, (FRAME_HEIGHT - font.height) / 2, .Red, "Yer Dead!")
}

draw_credits :: proc(core: ^Core) {
	fill_all(core, .Black)
	font, small := &FONTS[.Text], &FONTS[.Small]
	lines := CREDITS_PAGES[core.credits_page]
	y := (FRAME_HEIGHT - len(lines) * font.height) / 2
	for line, i in lines {
		write_centered(core, font, HALF_WIDTH, y, .Yellow if i == 0 else .Light_Gray, line)
		y += font.height
	}
	// "2/4" at the bottom, so the player knows how many pages are left
	buffer: [8]u8
	page := format_count(buffer[:], core.credits_page + 1)
	write_centered(core, small, HALF_WIDTH, FRAME_HEIGHT - small.height, .Dark_Gray, page)
}
