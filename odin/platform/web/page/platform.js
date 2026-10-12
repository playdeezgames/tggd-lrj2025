// Browser side of the platform interface: draw one RGBA frame, turn keys into commands, store text.
(async function () {
	const FRAME_W = 64, FRAME_H = 64;
	const COMMAND = { up: 1, down: 2, left: 3, right: 4, green: 5, red: 6, blue: 7, yellow: 8 };
	const debugLog = new URLSearchParams(location.search).has("log"); // ?log=1 prints every input sent to the game
	const logInput = (...a) => { if (debugLog) console.log("[input]", ...a); };

	const seedParam = new URLSearchParams(location.search).get("seed");
	const fixedSeed = seedParam !== null && /^\d{1,9}$/.test(seedParam) ? Number(seedParam) : null;
	let fixedSeedHalf = 0;

	const mem = new odin.WasmMemoryInterface();
	const platformImports = {
		// ?seed=N fixes the random numbers (bug reports, tests): the high word is 0 and the low word is N
		js_entropy_u32() {
			if (fixedSeed !== null) { fixedSeedHalf ^= 1; return fixedSeedHalf ? 0 : fixedSeed; }
			return crypto.getRandomValues(new Uint32Array(1))[0] | 0;
		},
		js_log(p, n) { console.log(mem.loadString(p, n)); },
	};
	await odin.runWasm("platform.wasm", null, { ...storageImports(mem), platform: platformImports }, mem);
	const exports = mem.exports;

	// ---- layout: the largest whole multiple of the frame that fits, else a smooth fit; centred ---------------
	const canvas = document.getElementById("screen"), ctx = canvas.getContext("2d");
	let laidOutFor = "";
	function layout() {
		const w = innerWidth, h = innerHeight;
		laidOutFor = w + "x" + h;
		if (w === 0 || h === 0) return;
		let scale = Math.min(w / FRAME_W, h / FRAME_H);
		if (scale >= 1) scale = Math.floor(scale);
		const cw = Math.floor(FRAME_W * scale), ch = Math.floor(FRAME_H * scale);
		canvas.style.width = cw + "px"; canvas.style.height = ch + "px";
		canvas.style.left = Math.floor((w - cw) / 2) + "px"; canvas.style.top = Math.floor((h - ch) / 2) + "px";
	}
	addEventListener("resize", layout); layout();

	// ---- input. The original's table (Pages/Home.razor CommandTable), matched on the logical key e.key. -----
	// Case-sensitive like the original (Shift or Caps Lock stops letters working): a quirk to decide later.
	// Held keys repeat, as in the original. Remote desktops can send wrong e.code values, so e.key comes first.
	const KEYS_BY_KEY = {
		q: "left", z: "up", w: "up", a: "left", s: "down", d: "right",
		ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right",
		" ": "green", Enter: "blue", Tab: "yellow", Backspace: "red",
	};
	addEventListener("keydown", (e) => {
		const name = KEYS_BY_KEY[e.key];
		if (!name) return;
		e.preventDefault();
		logInput("key", e.key, e.code, "->", name);
		exports.platform_command(COMMAND[name]);
	});
	addEventListener("contextmenu", (e) => e.preventDefault());

	// ---- the frame loop ---------------------------------------------------------------------------------
	let prev = performance.now();
	function frame(now) {
		if (laidOutFor !== innerWidth + "x" + innerHeight) layout(); // a pane that was hidden at load reports 0 by 0
		exports.platform_frame(Math.min((now - prev) / 1000, 0.25), Date.now()); prev = now;
		const ptr = exports.platform_frame_ptr();
		if (ptr && exports.platform_frame_changed()) {
			ctx.putImageData(new ImageData(new Uint8ClampedArray(mem.memory.buffer, ptr, FRAME_W * FRAME_H * 4), FRAME_W, FRAME_H), 0, 0);
		}
		requestAnimationFrame(frame);
	}
	window.__platform = { exports, mem };
	requestAnimationFrame(frame);
})();
