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
