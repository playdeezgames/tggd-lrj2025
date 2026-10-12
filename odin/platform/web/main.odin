#+build js
package main

// Browser platform (js_wasm32). odin.js runs `main` once (init); then page/platform.js calls `platform_frame` every
// animation frame. Everything crossing the boundary is a number, a (ptr, len) string, or a pointer into wasm memory.
import "base:runtime"
import "tggd:game"

foreign import platform_env "platform"

@(default_calling_convention = "contextless")
foreign platform_env {
	js_entropy_u32 :: proc() -> u32 ---
	js_log :: proc(message: string) ---
}

core: ^game.Core // allocated once at start; never on the stack
out: game.Step_Output
events: [64]game.Input_Event
event_count: int

main :: proc() {
	core = new(game.Core)
	game.core_init(core, game.Services{
		storage_get = storage_get, storage_set = storage_set, storage_remove = storage_remove,
		entropy = proc() -> u64 {
			high := js_entropy_u32() // two statements: the order of two calls in one expression is not guaranteed
			low := js_entropy_u32()
			return u64(high) << 32 | u64(low)
		},
		log = proc(message: string) { js_log(message) },
	})
}

// ---- exports called by page/platform.js ---------------------------------------------------------
@(export) platform_command :: proc "c" (command: i32) {
	if event_count < len(events) {
		events[event_count] = {command = game.Command(command)}
		event_count += 1
	}
}
// now_ms is the wall clock in milliseconds (an f64: int is 32 bits here)
@(export) platform_frame :: proc "c" (dt, now_ms: f64) {
	context = runtime.default_context()
	if core == nil { return }
	game.core_step(core, {dt = dt, now_ms = now_ms, events = events[:event_count]}, &out)
	event_count = 0
	free_all(context.temp_allocator)
}
@(export) platform_frame_ptr :: proc "c" () -> rawptr { return out.frame }
@(export) platform_frame_changed :: proc "c" () -> bool { return out.frame_changed }

// Sounds: the page asks for the file table once, then after every frame for the sounds that step queued.
@(export) platform_sfx_file_count :: proc "c" () -> i32 { return i32(len(game.Sfx)) }
@(export) platform_sfx_file_ptr :: proc "c" (sfx: i32) -> rawptr {
	files := game.SFX_FILES
	return raw_data(files[game.Sfx(sfx)])
}
@(export) platform_sfx_file_len :: proc "c" (sfx: i32) -> i32 {
	files := game.SFX_FILES
	return i32(len(files[game.Sfx(sfx)]))
}
@(export) platform_sfx_count :: proc "c" () -> i32 { return i32(out.sfx_count) }
@(export) platform_sfx_at :: proc "c" (i: i32) -> i32 { return i32(out.sfx[i]) }

// QA: show a room with the avatar at (column, row); kind is a Map_Type (0 starting, 1 ending, 2 room).
@(export) platform_debug_room :: proc "c" (kind, column, row: i32) {
	context = runtime.default_context()
	if core == nil { return }
	game.debug_show_room(core, game.Map_Type(clamp(kind, 0, 2)), int(column), int(row))
}

// QA: feed one command (1 up, 2 down, 3 left, 4 right, 5 green, 6 red, 7 blue, 8 yellow) and step once, even when the
// page's frame loop is not running (a hidden pane).
@(export) platform_debug_press :: proc "c" (command: i32) {
	context = runtime.default_context()
	if core == nil { return }
	events := [1]game.Input_Event{{command = game.Command(command)}}
	game.core_step(core, {events = events[:]}, &out)
	core.dirty = true // so the next real frame repaints even though this step consumed the change
	free_all(context.temp_allocator)
}
