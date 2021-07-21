"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OPEN_COMMAND = void 0;
const vscode = __importStar(require("vscode"));
const vscode_1 = require("vscode");
const utils_1 = require("../utils");
const foam_core_1 = require("foam-core");
const vsc_utils_1 = require("../utils/vsc-utils");
exports.OPEN_COMMAND = {
    command: 'foam-vscode.open-resource',
    title: 'Foam: Open Resource',
    execute: async (params) => {
        const { uri } = params;
        switch (uri.scheme) {
            case 'file':
                return vscode.commands.executeCommand('vscode.open', vsc_utils_1.toVsCodeUri(uri));
            case 'placeholder':
                const newNote = await utils_1.createNoteFromPlaceholder(uri);
                if (utils_1.isSome(newNote)) {
                    const title = uri.path.split('/').slice(-1);
                    const snippet = new vscode.SnippetString('# ${1:' + title + '}\n\n$0');
                    await utils_1.focusNote(newNote, true);
                    await vscode.window.activeTextEditor.insertSnippet(snippet);
                }
                return;
        }
    },
    asURI: (uri) => vscode.Uri.parse(`command:${exports.OPEN_COMMAND.command}`).with({
        query: encodeURIComponent(JSON.stringify({ uri: foam_core_1.URI.create(uri) })),
    }),
};
const feature = {
    activate: (context) => {
        context.subscriptions.push(vscode_1.commands.registerCommand(exports.OPEN_COMMAND.command, exports.OPEN_COMMAND.execute));
    },
};
exports.default = feature;
//# sourceMappingURL=utility-commands.js.map