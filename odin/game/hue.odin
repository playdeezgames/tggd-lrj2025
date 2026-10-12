package game

// The original's 24-colour palette (Grimoire/Hue.vb for the order, Pages/Home.razor for the values).
// The core draws in hue indices; conversion to RGBA happens once per frame at the end.

Hue :: enum u8 {
	Black,
	Blue,
	Green,
	Cyan,
	Red,
	Magenta,
	Brown,
	Light_Gray,
	Dark_Gray,
	Light_Blue,
	Light_Green,
	Light_Cyan,
	Light_Red,
	Light_Magenta,
	Yellow,
	White,
	Darker_Gray,
	Dark_Blue,
	Dark_Green,
	Dark_Cyan,
	Dark_Red,
	Dark_Magenta,
	Dark_Yellow,
	Medium_Gray,
}

// 0xAABBGGRR, so the bytes in memory are R,G,B,A as ImageData wants them.
PALETTE :: [Hue]u32 {
	.Black         = 0xFF000000, // #000
	.Blue          = 0xFFAA0000, // #00a
	.Green         = 0xFF00AA00, // #0a0
	.Cyan          = 0xFFAAAA00, // #0aa
	.Red           = 0xFF0000AA, // #a00
	.Magenta       = 0xFFAA00AA, // #a0a
	.Brown         = 0xFF0055AA, // #a50
	.Light_Gray    = 0xFFAAAAAA, // #aaa
	.Dark_Gray     = 0xFF555555, // #555
	.Light_Blue    = 0xFFFF5555, // #55f
	.Light_Green   = 0xFF55FF55, // #5f5
	.Light_Cyan    = 0xFFFFFF55, // #5ff
	.Light_Red     = 0xFF5555FF, // #f55
	.Light_Magenta = 0xFFFF55FF, // #f5f
	.Yellow        = 0xFF55FFFF, // #ff5
	.White         = 0xFFFFFFFF, // #fff
	.Darker_Gray   = 0xFF282828, // #282828
	.Dark_Blue     = 0xFF802828, // #282880
	.Dark_Green    = 0xFF288028, // #288028
	.Dark_Cyan     = 0xFF808028, // #288080
	.Dark_Red      = 0xFF282880, // #802828
	.Dark_Magenta  = 0xFF802880, // #802880
	.Dark_Yellow   = 0xFF288080, // #808028
	.Medium_Gray   = 0xFF808080, // #808080
}
