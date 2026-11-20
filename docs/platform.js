// Browser side of the platform interface: draw one RGBA frame, turn keys into commands, store text.
(async function () {
	const FRAME_W = 64, FRAME_H = 64;
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
	// With touch controls showing, either they sit in the side margins (a wide window) or a band is kept free below.
	const canvas = document.getElementById("screen"), ctx = canvas.getContext("2d");
	const pads = document.getElementById("pads");
	let touchControls = matchMedia("(pointer: coarse)").matches; // shown at once on phones, after the first touch elsewhere
	let laidOutFor = "";
	function layout() {
		const w = innerWidth, h = innerHeight;
		laidOutFor = w + "x" + h + (touchControls ? "t" : "");
		if (w === 0 || h === 0) return;
		let areaW = w, areaH = h, padsMode = "";
		if (touchControls) {
			if ((w - h) / 2 >= 150) { padsMode = "sides"; areaW = h; }          // a square canvas, controls left and right
			else { padsMode = "band"; areaH = h - Math.min(Math.round(h * 0.4), 260); } // controls in a band below
		}
		let scale = Math.min(areaW / FRAME_W, areaH / FRAME_H);
		if (scale >= 1) scale = Math.floor(scale);
		const cw = Math.floor(FRAME_W * scale), ch = Math.floor(FRAME_H * scale);
		const left = Math.floor((w - cw) / 2), top = Math.floor((areaH - ch) / 2);
		canvas.style.width = cw + "px"; canvas.style.height = ch + "px";
		canvas.style.left = left + "px"; canvas.style.top = top + "px";
		layoutPads(padsMode, w, h, left, cw, areaH);
	}
	addEventListener("resize", layout);

	// ---- touch controls: a d-pad that repeats while held, and the two action buttons ------------------------
	const padButtons = {};
	function makeButton(name, label, command, repeat) {
		const b = document.createElement("button");
		b.className = "pad pad-" + name;
		b.textContent = label;
		b.setAttribute("aria-label", name);
		let timer = 0, interval = 0;
		const stop = () => { clearTimeout(timer); clearInterval(interval); b.classList.remove("down"); };
		b.addEventListener("pointerdown", (e) => {
			e.preventDefault();
			try { b.setPointerCapture(e.pointerId); } catch (err) {}
			b.classList.add("down");
			logInput("pad", name);
			exports.platform_command(command);
			if (repeat) timer = setTimeout(() => { interval = setInterval(() => exports.platform_command(command), 110); }, 380);
		});
		for (const type of ["pointerup", "pointercancel", "lostpointercapture"]) b.addEventListener(type, stop);
		b.addEventListener("contextmenu", (e) => e.preventDefault());
		pads.appendChild(b);
		padButtons[name] = b;
	}
	makeButton("up", "\u25B2", COMMAND.up, true);
	makeButton("left", "\u25C0", COMMAND.left, true);
	makeButton("right", "\u25B6", COMMAND.right, true);
	makeButton("down", "\u25BC", COMMAND.down, true);
	makeButton("green", "OK", COMMAND.green, false);
	makeButton("red", "BACK", COMMAND.red, false);

	function layoutPads(mode, w, h, canvasLeft, canvasW, areaH) {
		pads.style.display = mode ? "block" : "none";
		if (!mode) return;
		// the d-pad is a 3 by 3 grid of cells; the buttons are two cells stacked
		let cell, dx, dy, bx, by, stack;
		if (mode === "sides") {
			cell = Math.min(Math.floor(canvasLeft / 3.4), 90);
			dx = Math.floor((canvasLeft - cell * 3) / 2); dy = Math.floor((h - cell * 3) / 2);
			bx = canvasLeft + canvasW + Math.floor((canvasLeft - cell * 1.6) / 2); by = Math.floor((h - cell * 3.4) / 2); stack = true;
		} else {
			const band = h - areaH;
			cell = Math.min(Math.floor(band / 3.3), Math.floor(w / 7), 84);
			dx = Math.max(Math.floor(w * 0.04), 8); dy = areaH + Math.floor((band - cell * 3) / 2);
			bx = w - Math.max(Math.floor(w * 0.04), 8) - Math.floor(cell * 1.7); by = areaH + Math.floor((band - cell * 3.4) / 2); stack = true;
		}
		const place = (name, x, y, wd, ht) => {
			const s = padButtons[name].style;
			s.left = x + "px"; s.top = y + "px"; s.width = wd + "px"; s.height = ht + "px"; s.fontSize = Math.floor(cell * 0.38) + "px";
		};
		place("up", dx + cell, dy, cell, cell);
		place("left", dx, dy + cell, cell, cell);
		place("right", dx + cell * 2, dy + cell, cell, cell);
		place("down", dx + cell, dy + cell * 2, cell, cell);
		const bw = Math.floor(cell * 1.7), bh = Math.floor(cell * 1.5);
		place("green", bx, by, bw, bh);
		place("red", bx, by + bh + Math.floor(cell * 0.4), bw, bh);
	}

	// ---- input. The original's key table (input.js), matched on the logical key e.key: remote desktops can send ----
	// wrong e.code values. Held keys repeat, as in the original.
	addEventListener("keydown", (e) => {
		const name = commandForKey(e.key, e);
		if (!name) return;
		e.preventDefault();
		logInput("key", e.key, e.code, "->", name);
		exports.platform_command(COMMAND[name]);
	});
	addEventListener("contextmenu", (e) => e.preventDefault());
	// the first touch anywhere shows the controls on a laptop with a touch screen; a click focuses the page (itch.io iframe)
	addEventListener("pointerdown", (e) => {
		try { window.focus(); } catch (err) {}
		if (e.pointerType === "touch" && !touchControls) { touchControls = true; layout(); }
	}, true);
	layout();

	// ---- sound: the core owns the file table; one Audio element per effect, restarted on each play (as the original) ----
	const sounds = [];
	for (let i = 0; i < exports.platform_sfx_file_count(); i++) {
		const a = new Audio(mem.loadString(exports.platform_sfx_file_ptr(i), exports.platform_sfx_file_len(i)));
		a.preload = "auto";
		sounds.push(a);
	}
	function playSounds() {
		for (let i = 0, n = exports.platform_sfx_count(); i < n; i++) {
			const a = sounds[exports.platform_sfx_at(i)];
			logInput("sfx", a.src);
			try { a.currentTime = 0; a.play().catch(() => {}); } catch (e) {}
		}
	}

	// ---- the frame loop ---------------------------------------------------------------------------------
	let prev = performance.now();
	function frame(now) {
		if (laidOutFor !== innerWidth + "x" + innerHeight) layout(); // a pane that was hidden at load reports 0 by 0
		exports.platform_frame(Math.min((now - prev) / 1000, 0.25), Date.now()); prev = now;
		playSounds();
		const ptr = exports.platform_frame_ptr();
		if (ptr && exports.platform_frame_changed()) {
			ctx.putImageData(new ImageData(new Uint8ClampedArray(mem.memory.buffer, ptr, FRAME_W * FRAME_H * 4), FRAME_W, FRAME_H), 0, 0);
		}
		requestAnimationFrame(frame);
	}
	// ?room=0|1|2&x=N&y=N shows the starting room, the ending room or a room with the avatar at (x, y) (QA)
	const q = new URLSearchParams(location.search);
	if (q.has("room")) exports.platform_debug_room(Number(q.get("room")) | 0, Number(q.get("x") ?? 7) | 0, Number(q.get("y") ?? 7) | 0);
	window.__platform = { exports, mem };
	requestAnimationFrame(frame);
})();
