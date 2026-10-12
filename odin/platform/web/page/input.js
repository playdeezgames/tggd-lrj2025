// Keyboard and touch input rules, kept free of the DOM so tools/input_test.js can run them under node.
// The table is the original's (Pages/Home.razor CommandTable) with letters matched regardless of case.
const COMMAND = { up: 1, down: 2, left: 3, right: 4, green: 5, red: 6, blue: 7, yellow: 8 };

const KEYS_BY_KEY = {
	q: "left", z: "up", w: "up", a: "left", s: "down", d: "right",
	ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right",
	" ": "green", Enter: "blue", Tab: "yellow", Backspace: "red",
};

// The command name for a key event's logical key (e.key), or null. Letters match in either case; Ctrl, Alt and Meta
// combinations are left to the browser (Ctrl+W, Cmd+Q, ...).
function commandForKey(key, mods) {
	if (mods && (mods.ctrlKey || mods.altKey || mods.metaKey)) return null;
	const k = key.length === 1 ? key.toLowerCase() : key;
	return Object.prototype.hasOwnProperty.call(KEYS_BY_KEY, k) ? KEYS_BY_KEY[k] : null;
}

if (typeof module !== "undefined") module.exports = { COMMAND, KEYS_BY_KEY, commandForKey };
