// Checks the page's key table (run by tools/test.sh): node tools/input_test.js
const assert = require("assert");
const path = require("path");
const { COMMAND, commandForKey } = require(path.join(__dirname, "../odin/platform/web/page/input.js"));

const expectKey = (key, name, mods) => assert.strictEqual(commandForKey(key, mods), name, `${JSON.stringify(key)} -> ${name}`);

// the original's table
for (const [k, n] of Object.entries({ q: "left", z: "up", w: "up", a: "left", s: "down", d: "right",
	ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right", " ": "green", Enter: "blue", Tab: "yellow", Backspace: "red" })) {
	expectKey(k, n);
}
// letters work with Shift or Caps Lock (decided with the project owner)
for (const [k, n] of Object.entries({ Q: "left", Z: "up", W: "up", A: "left", S: "down", D: "right" })) expectKey(k, n);
// things that must not be taken
for (const k of ["Escape", "x", "1", "F5", "Shift", "Control", "Dead", "", "toString", "__proto__"]) expectKey(k, null);
// browser shortcuts are left alone
expectKey("w", null, { ctrlKey: true });
expectKey("s", null, { metaKey: true });
expectKey("a", null, { altKey: true });
// the command numbers are the Odin side's `Command` enum order (read from api.odin, so they cannot drift)
const api = require("fs").readFileSync(path.join(__dirname, "../odin/game/api.odin"), "utf8");
const order = /Command :: enum u8 \{([^}]*)\}/.exec(api)[1].split(",").map((s) => s.trim().toLowerCase()).filter(Boolean);
assert.strictEqual(order[0], "none");
order.slice(1).forEach((name, i) => assert.strictEqual(COMMAND[name], i + 1, `command ${name}`));
assert.strictEqual(Object.keys(COMMAND).length, order.length - 1);
console.log("input_test: ok");
