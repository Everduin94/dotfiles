"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const dated_notes_1 = require("../dated-notes");
const feature = {
    activate: (context) => {
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.open-daily-note', dated_notes_1.openDailyNoteFor));
        if (vscode_1.workspace.getConfiguration('foam').get('openDailyNote.onStartup', false)) {
            vscode_1.commands.executeCommand('foam-vscode.open-daily-note');
        }
    },
};
exports.default = feature;
//# sourceMappingURL=open-daily-note.js.map