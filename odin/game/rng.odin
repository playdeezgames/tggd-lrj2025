package game

// The game's own generator (splitmix64), so a seed gives the same rolls on every target and tests can seed it.
// (The original used System.Random; its sequences are not reproducible, so none are matched.)

Rng :: struct { state: u64 }

rng_seed :: proc(r: ^Rng, seed: u64) { r.state = seed }

rng_next :: proc(r: ^Rng) -> u64 {
	r.state += 0x9E3779B97F4A7C15
	z := r.state
	z = (z ~ (z >> 30)) * 0xBF58476D1CE4E5B9
	z = (z ~ (z >> 27)) * 0x94D049BB133111EB
	return z ~ (z >> 31)
}

// A uniform integer in [lo, hi] (inclusive), without modulo bias. Requires lo <= hi.
rng_range :: proc(r: ^Rng, lo, hi: int) -> int {
	span := u64(hi - lo) + 1
	limit := (max(u64) / span) * span // draws at or above this would favour the low values
	for {
		x := rng_next(r)
		if x < limit { return lo + int(x % span) }
	}
}
