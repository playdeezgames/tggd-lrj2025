package game

// Drawing into the hue buffer. Everything works on palette indices; present() converts them to RGBA.
// Clipping is per pixel, like the original's UIBuffer.SetPixel.

// A bitmap font: `count` glyphs starting at character `first`, `height` rows each, one u16 per row (bit x is the pixel
// in column x). Each glyph has its own advance. A character outside the stored range draws nothing and advances by
// `space`. The data is generated (font_data.odin); the sprite sheet is a Font too, with advance 10.
Font :: struct {
	height:        int,
	first, count:  int,
	space:         int,
	advance:       []u8,
	rows:          []u16,
}

set_pixel :: proc(core: ^Core, x, y: int, hue: Hue) {
	if x < 0 || y < 0 || x >= FRAME_WIDTH || y >= FRAME_HEIGHT { return }
	core.hues[x + y * FRAME_WIDTH] = u8(hue)
}

fill_rect :: proc(core: ^Core, x, y, w, h: int, hue: Hue) {
	for row in y ..< y + h {
		for column in x ..< x + w {
			set_pixel(core, column, row, hue)
		}
	}
}

fill_all :: proc(core: ^Core, hue: Hue) {
	fill_rect(core, 0, 0, FRAME_WIDTH, FRAME_HEIGHT, hue)
}

// Draws one glyph with its top-left at (x, y); only the set pixels are written (the background shows through).
write_glyph :: proc(core: ^Core, font: ^Font, x, y: int, hue: Hue, char: u8) {
	index := int(char) - font.first
	if index < 0 || index >= font.count { return }
	for row in 0 ..< font.height {
		bits := font.rows[index * font.height + row]
		for column in 0 ..< 16 {
			if bits & (1 << uint(column)) != 0 { set_pixel(core, x + column, y + row, hue) }
		}
	}
}

glyph_advance :: proc(font: ^Font, char: u8) -> int {
	index := int(char) - font.first
	if index < 0 || index >= font.count { return font.space }
	return int(font.advance[index])
}

// Draws text and returns the x just past it, like the original's UIFont.Write.
write_text :: proc(core: ^Core, font: ^Font, x, y: int, hue: Hue, text: string) -> int {
	x := x
	for char in transmute([]u8)text {
		write_glyph(core, font, x, y, hue, char)
		x += glyph_advance(font, char)
	}
	return x
}

text_width :: proc(font: ^Font, text: string) -> int {
	width := 0
	for char in transmute([]u8)text { width += glyph_advance(font, char) }
	return width
}

// The original centres on the integer half of the width (column - width \ 2).
write_centered :: proc(core: ^Core, font: ^Font, x, y: int, hue: Hue, text: string) {
	write_text(core, font, x - text_width(font, text) / 2, y, hue, text)
}

// Like write_centered, but when the text is wider than `limit` it takes one pixel of spacing out after enough glyphs,
// spread evenly, to fit. (The original's monospace 3x5 font made "TheGrumpyGameDev" exactly 64 wide; the proportional
// replacement is a few pixels wider.)
write_centered_fitted :: proc(core: ^Core, font: ^Font, x, y: int, hue: Hue, text: string, limit: int) {
	excess := text_width(font, text) - limit
	if excess <= 0 {
		write_centered(core, font, x, y, hue, text)
		return
	}
	n := len(text)
	step := max(n / excess, 1)
	cx := x - (text_width(font, text) - excess) / 2
	removed := 0
	for i in 0 ..< n {
		char := text[i]
		write_glyph(core, font, cx, y, hue, char)
		cx += glyph_advance(font, char)
		if removed < excess && i % step == step - 1 {
			cx -= 1
			removed += 1
		}
	}
}
