package game

// Drawing into the hue buffer. Everything works on palette indices; present() converts them to RGBA.
// Clipping is per pixel, like the original's UIBuffer.SetPixel.

// A fixed-width bitmap font: `count` glyphs starting at character `first`, `height` rows each, one u16 per row
// (bit x is the pixel in column x). A character outside the stored range draws nothing and still advances by `width`.
// The font data itself lives apart from this engine (see Font_Id / FONTS once fonts are chosen).
Font :: struct {
	width, height: int,
	first, count:  int,
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
		for column in 0 ..< font.width {
			if bits & (1 << uint(column)) != 0 { set_pixel(core, x + column, y + row, hue) }
		}
	}
}

// Draws text and returns the x just past it, like the original's UIFont.Write.
write_text :: proc(core: ^Core, font: ^Font, x, y: int, hue: Hue, text: string) -> int {
	x := x
	for char in transmute([]u8)text {
		write_glyph(core, font, x, y, hue, char)
		x += font.width
	}
	return x
}

text_width :: proc(font: ^Font, text: string) -> int {
	return len(text) * font.width
}

// The original centres on the integer half of the width (column - width \ 2).
write_centered :: proc(core: ^Core, font: ^Font, x, y: int, hue: Hue, text: string) {
	write_text(core, font, x - text_width(font, text) / 2, y, hue, text)
}
