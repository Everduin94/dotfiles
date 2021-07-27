"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const utils_1 = require("../utils");
const feature = {
    activate: (context) => {
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.copy-without-brackets', copyWithoutBrackets));
    },
};
async function copyWithoutBrackets() {
    // Get the active text editor
    const editor = vscode_1.window.activeTextEditor;
    if (editor) {
        const document = editor.document;
        const selection = editor.selection;
        // Get the words within the selection
        const text = document.getText(selection);
        // Remove brackets from text
        const modifiedText = utils_1.removeBrackets(text);
        // Copy to the clipboard
        await vscode_1.env.clipboard.writeText(modifiedText);
        // Alert the user it was successful
        vscode_1.window.showInformationMessage('Successfully copied to clipboard!');
    }
}
exports.default = feature;
//# sourceMappingURL=copy-without-brackets.js.map