// Why does eslint not work right in cx-platform?
// Why does my tsconfig have to be updated to include lib?
class Testing {
  name = "Erik"; // Why are my snippets not in my blink list? (But preconfigured ones are???)
  age = 31; // Why is inline hints on by default?
  married = true;

  constructor() {} // Why does copilot only do 1 line?

  log_me() {} // Why does the cursor go in the wrong spot when making curly braces?

  // And went to the correct spot here... why did it not work earlier?
  help() {}
}

if (



) {
  
}

// Cursor goes to correct spot here.
function help() {}

function wow() {}

if ('testing testing') {
  
}


console.log("something");
console.log("anotherthin okay");

if (true) {

}const my_var = "hello";

if ("testing") {
  
}console.log("");

console.log("world");
function multiply(a: number, b: number): number {
  return a * b;
}

console.log("something");
console.debug;

structuredClone;
console.log('wow', wow);

console.log('wowo', wowo);
console.log('', );
console.log('', structuredClone);

/**
 * Snippet ideas:
 * - Something like a snippet for if, doesn't really help that much.
 *   - Because, the moment you exapnd the snippet, you think. What is the condition? What is the body?
 *   - Basically, you may do that thing a split second faster, but then you have to think about what goes in there.
 *   - With AI too, you could write out what the condition / body is in a comment prior, then it would fill it out for you.
 * - Snippets would probably be more helpful on things that we constantly forget.
 *   - Which to be fair, in other languages, technically is `if` statements and simple things like that.
 * - Additionally, snippets might be significantly faster for redundant operations.
 *   - If I write setTimeout, I'm almost always wrapping an existing thing in there. How can we repurpose visual selection?
 *   - If I write an if statement, then an if-else or else. I basically always have to exit insert mode, go down to the squiggly brace, and type the else.
 * - Thus, I like our new vim.ui.select for snippets. What we could add to make it useful:
 *   - More complex blocks that are repetitive or hard to remember.
 *   - Treesitter integration to put things in the right spot.
 *   - Optional visual integration to wrap existing code in snippets.
 */

console.log('structuredClone', structuredClone);


console.log('', structuredClone);
console.log('', structuredClone);
1

console.log('', console.log('wow', wow);  );


console.log('structuredClone', structuredClone);  
1

console.log('', );


if (true) {

}const str = "hello";
str.replace("2", "3");

if (true) {

}str.replace("wow", "this is so good");

str.replace("wow", replaceValue);
strif (true) {

}.replace("wow", "again");

if (condition) {

}console.log("wow");
do {} while (true);

str.endsWith;
str.charAt(pos);
str.charAt(2);
str.charAt;

/**
vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#bac2de" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#7dc4e4", bg = "NONE" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#313244" }) -- blue fg, soft bg

*/

// #f5e0dc
// #f2cdcd
// #f5c2e7
// #b4befe
// #bac2de
// #a6adc8
// #f9e2af
// #89dceb
// #74c7ec
// #94e2d5


function playSound(filename: string) {
 try {
  const audio = new Audio(`resources/${filename}`);
  audio.volume = 0.5;
  audio.play().catch(() => {});
 } catch (e) {
  // Ignore audio errors
 } 
}


class Helper {

  constructor() {

  }

  wow(name: string) {
    console.log("Hello, " + name);
  }

}





/**
 *

Treesitter
  - @variable.typescript links to @variable   priority: 100   language: typescript
  - @variable.parameter.typescript links to @variable.parameter   priority: 100   language: typescript

Semantic Tokens
  - @lsp.type.parameter.typescript links to @parameter   priority: 125
  - @lsp.mod.declaration.typescript priority: 126
  - @lsp.typemod.parameter.declaration.typescript priority: 127

Extmarks
  - LspReferenceRead nvim.lsp.references



Treesitter
  - @variable.typescript links to @variable   priority: 100   language: typescript

Semantic Tokens
  - @lsp.type.variable.typescript links to @lsp.type.variable   priority: 125
  - @lsp.mod.declaration.typescript priority: 126
  - @lsp.mod.local.typescript links to @lsp   priority: 126
  - @lsp.typemod.variable.declaration.typescript links to @lsp   priority: 127
  - @lsp.typemod.variable.local.typescript links to @lsp   priority: 127

Extmarks
  - LspReferenceRead nvim.lsp.references


 *
 * */


if (true) {
  // hello there else if (
  str.forEach(element => {
    
  });  
  }!  
}


if (true) {
  str.charAt(2);
}

if (true) {
  
}




if (true) {
  str.charAt(2);
}

str.substring(2);

if (condition) {
  if (true) {
  str.substring(3);
}
}

if (false) {
  
}

text: 12345
copy: 12345

text: 00000
copy: 00000 

text: 123
copy: 123
Ending

if (true) {
  
}
console.log("testing");
str.replace("1", "2");

if (true) {
  
}str.replace("1", replaceValue);

str.toLo;
text: 1234
copy: 1234
Ending

if (wowwww) {
wowwww
}

if (true) {
  testing testing
}

if (true) {
  
}
if (true) {
}const result = multiply(5, 10);

console.log("Result:", result);

console.log("Final log");

console.log("The end");

console.log("snippets");

console.log();

// 123456789 qwerty asdfg zxcv uiop hkjkl
//
//
// a all
// f flow
// s svelte/angular/whatever
// msq msw mse msr ms1 ms2 ms3 ms4
//  m1 m2 m3 mq mw me mr mt my mu mo mi mp ml ma ms md mf mg mz mx mc mv mb mg mh m mm1 mm2 mm3 mma mmq mm

SVGAnimatedInteger;

SVGForeignObjectElement;

SVGMPathElement;

SVGMarkerElement;

SVGMarkerElement;
SVGForeignObjectElement;

SVGPathElement;

SVGMarkerElement;

SVGMarkerElement.apply;

// Ctrl+y uses both hands. Maybe better than ctrl+f for that reason.
// You only need enter for `import` and `snippets`.
//  If you don't use snippets like this. Then only import...
//  i.e., you could basically just tab your way to everything except imports.
// I think I don't like enter accept because it makes me hesitant to hit enter for new lines.
// Tab for cycling seems nice because I actually use my ring finger
// Tab also seems really nice because my sub modes only work in normal mode. Not insert.

// copilot suggestions only uses specific models. You can't configure it.

/**
 * Concepts:
 * - I would like to see cycling done via tab (no pinky)
 * - I would like to see accept on enter (no pinky), already done.
 *   Tangent: why does my list go here?
 * - I would like to put copilot accept on a different key (potentially pinky)
 * - I would like for my snippets like ma1 or ms2 to show up in my blink list.
 *   - AND be easier to do from insertion. Maybe ctrl+m exits or something idk
 *   - AND work better with tree-sitter. For example, put an else if in the right spot.
 * - I want to turn ghost test off completely (outside of a copilot suggestion). It's annoying as hell
 * - I want the ability to turn copilot auto off.
 */
