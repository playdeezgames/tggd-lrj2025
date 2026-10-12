package game

// The platform interface: everything the portable core exchanges with a platform.
// The core never imports a platform package; platforms never reach into core state.
//
//   platform -> core:  Input_Event list per frame, dt, the wall clock, and Services supplied once at init
//   core -> platform:  Step_Output per frame (pixels) and synchronous calls through Services

import "base:runtime"

// ---- fixed geometry: the original's 64 by 64 buffer of palette indices ---------------------------
FRAME_WIDTH :: 64
FRAME_HEIGHT :: 64

// ---- input: the original's eight abstract commands (Grimoire/Command.vb) --------------------------
// The page maps keys to these; the core never sees a key.
Command :: enum u8 { None, Up, Down, Left, Right, Green, Red, Blue, Yellow }

Input_Event :: struct {
	command: Command,
}

// ---- output --------------------------------------------------------------------------------------
Step_Output :: struct {
	frame:         ^[FRAME_WIDTH * FRAME_HEIGHT]u32, // bytes in memory order R,G,B,A (little-endian u32 0xAABBGGRR)
	frame_changed: bool,
	sfx:           [SFX_QUEUE_SIZE]Sfx, // sounds this step asked for, in order; the first sfx_count are valid
	sfx_count:     int,
}

Step_Input :: struct {
	dt:     f64, // seconds since the previous step (presentation only)
	now_ms: f64, // wall clock, milliseconds since the Unix epoch; f64 because int is 32 bits on wasm
	events: []Input_Event,
}

// ---- services (platform functions the core calls synchronously) ----------------------------------
// Supplied once to core_init, so the core has no platform imports and tests can pass fakes.
// Any of them may be nil.
Services :: struct {
	storage_get:    proc(key: string, allocator: runtime.Allocator) -> (value: string, ok: bool),
	storage_set:    proc(key, value: string) -> bool, // false on quota or when storage is unavailable
	storage_remove: proc(key: string),
	entropy:        proc() -> u64, // for seeding; not reproducible
	log:            proc(message: string),
}
