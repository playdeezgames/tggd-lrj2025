package game

// Tables of facts about each type: what the original keeps in descriptor classes and display-property modules.

// ---- display (UI/DisplayProperties) --------------------------------------------------------------
Display :: struct {
	sprite: Sprite,
	hue:    Hue,
}

LOCATION_DISPLAY :: [Location_Type]Display {
	.Starting_Room_Floor = {.Floor, .Darker_Gray},
	.Room_Floor          = {.Floor, .Darker_Gray},
	.Ending_Room_Floor   = {.Floor, .Darker_Gray},
	.Blue_Wall           = {.Wall, .Blue},
	.Gray_Wall           = {.Wall, .Dark_Gray},
	.Door                = {.Door, .Brown},
	.Silver_Door         = {.Door, .Light_Gray},
	.Gold_Door           = {.Door, .Yellow},
	.Carnelian_Door      = {.Door, .Red},
	.Amethyst_Door       = {.Door, .Magenta},
	.Sapphire_Door       = {.Door, .Blue},
	.Ruby_Door           = {.Door, .Light_Red},
	.Emerald_Door        = {.Door, .Light_Green},
	.Final_Sign          = {.Sign, .Brown},
	.Sign                = {.Sign, .Brown},
}

ITEM_DISPLAY :: [Item_Type]Display {
	.Silver_Key   = {.Key, .Light_Gray},
	.Gold_Key     = {.Key, .Yellow},
	.Carnelian_Key = {.Key, .Red},
	.Amethyst_Key = {.Key, .Magenta},
	.Sapphire_Key = {.Key, .Blue},
	.Ruby_Key     = {.Key, .Light_Red},
	.Emerald_Key  = {.Key, .Light_Green},
	.Food         = {.Food, .Dark_Blue},
	.Sword        = {.Sword, .Light_Blue},
	.Shield       = {.Shield, .Light_Green},
	.Potion       = {.Potion, .Red},
}

CHARACTER_DISPLAY :: [Character_Type]Display {
	.N00b        = {.Player, .Brown},
	.Moon_Person = {.Moon_Person, .Dark_Gray},
}

is_solid :: proc(t: Location_Type) -> bool {
	#partial switch t {
	case .Starting_Room_Floor, .Room_Floor, .Ending_Room_Floor: return false
	}
	return true // walls, doors, signs
}

is_key :: proc(t: Item_Type) -> bool {
	return t >= .Silver_Key && t <= .Emerald_Key
}

// ---- characters (Character/CharacterType/Descriptor) ---------------------------------------------------
character_initial_stats :: proc(t: Character_Type) -> Stats {
	s: Stats
	switch t {
	case .N00b:
		stat_set_min(&s, .Health, 0); stat_set_max(&s, .Health, 100); stat_set(&s, .Health, 100)
		stat_set_min(&s, .Satiety, 0); stat_set_max(&s, .Satiety, 100); stat_set(&s, .Satiety, 100)
		stat_set(&s, .Attack, 10)
		stat_set(&s, .Defend, 5)
		stat_set(&s, .Sword_Durability, 0); stat_set_min(&s, .Sword_Durability, 0)
		stat_set(&s, .Shield_Durability, 0); stat_set_min(&s, .Shield_Durability, 0)
	case .Moon_Person:
		stat_set_min(&s, .Health, 0); stat_set_max(&s, .Health, 25); stat_set(&s, .Health, 25)
		stat_set(&s, .Attack, 20)
		stat_set(&s, .Defend, 0)
		stat_set(&s, .Shield_Durability, 0)
		stat_set(&s, .Sword_Durability, 0)
	}
	return s
}
