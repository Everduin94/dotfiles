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
exports.TagCompletionProvider = void 0;
const vscode = __importStar(require("vscode"));
const utils_1 = require("../utils");
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        context.subscriptions.push(vscode.languages.registerCompletionItemProvider(utils_1.mdDocSelector, new TagCompletionProvider(foam.tags), '#'));
    },
};
class TagCompletionProvider {
    constructor(foamTags) {
        this.foamTags = foamTags;
    }
    provideCompletionItems(document, position) {
        const cursorPrefix = document
            .lineAt(position)
            .text.substr(0, position.character);
        const requiresAutocomplete = cursorPrefix.match(/#(.*)/);
        if (!requiresAutocomplete) {
            return null;
        }
        const completionTags = [];
        [...this.foamTags.tags].forEach(([tag]) => {
            const item = new vscode.CompletionItem(tag, vscode.CompletionItemKind.Text);
            item.insertText = `${tag}`;
            item.documentation = tag;
            completionTags.push(item);
        });
        return new vscode.CompletionList(completionTags);
    }
}
exports.TagCompletionProvider = TagCompletionProvider;
exports.default = feature;
//# sourceMappingURL=tag-completion.js.map