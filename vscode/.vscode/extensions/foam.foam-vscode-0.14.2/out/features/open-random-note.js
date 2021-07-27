"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const foam_core_1 = require("foam-core");
const vscode_1 = require("vscode");
const utils_1 = require("../utils");
const feature = {
    activate: (context, foamPromise) => {
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.open-random-note', async () => {
            var _a;
            const foam = await foamPromise;
            const currentFile = (_a = vscode_1.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document.uri.path;
            const notes = foam.workspace
                .list()
                .filter(r => foam_core_1.URI.isMarkdownFile(r.uri));
            if (notes.length <= 1) {
                vscode_1.window.showInformationMessage('Could not find another note to open. If you believe this is a bug, please file an issue.');
                return;
            }
            let randomNoteIndex = Math.floor(Math.random() * notes.length);
            if (notes[randomNoteIndex].uri.path === currentFile) {
                randomNoteIndex = (randomNoteIndex + 1) % notes.length;
            }
            utils_1.focusNote(notes[randomNoteIndex].uri, false);
        }));
    },
};
exports.default = feature;
//# sourceMappingURL=open-random-note.js.map