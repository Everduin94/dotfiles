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
exports.CompletionProvider = void 0;
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const utils_1 = require("../utils");
const vsc_utils_1 = require("../utils/vsc-utils");
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        context.subscriptions.push(vscode.languages.registerCompletionItemProvider(utils_1.mdDocSelector, new CompletionProvider(foam.workspace, foam.graph), '['));
    },
};
class CompletionProvider {
    constructor(ws, graph) {
        this.ws = ws;
        this.graph = graph;
    }
    provideCompletionItems(document, position) {
        const cursorPrefix = document
            .lineAt(position)
            .text.substr(0, position.character);
        // Requires autocomplete only if cursorPrefix matches `[[` that NOT ended by `]]`.
        // See https://github.com/foambubble/foam/pull/596#issuecomment-825748205 for details.
        // eslint-disable-next-line no-useless-escape
        const requiresAutocomplete = cursorPrefix.match(/\[\[[^\[\]]*(?!.*\]\])/);
        if (!requiresAutocomplete) {
            return null;
        }
        const resources = this.ws.list().map(resource => {
            const item = new vscode.CompletionItem(vscode.workspace.asRelativePath(vsc_utils_1.toVsCodeUri(resource.uri)), vscode.CompletionItemKind.File);
            item.insertText = foam_core_1.URI.getBasename(resource.uri);
            item.documentation = utils_1.getNoteTooltip(resource.source.text);
            return item;
        });
        const placeholders = Array.from(this.graph.placeholders.values()).map(uri => {
            return new vscode.CompletionItem(uri.path, vscode.CompletionItemKind.Interface);
        });
        return new vscode.CompletionList([...resources, ...placeholders]);
    }
}
exports.CompletionProvider = CompletionProvider;
exports.default = feature;
//# sourceMappingURL=link-completion.js.map