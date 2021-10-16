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
exports.CONFIG_KEY = void 0;
const lodash_1 = require("lodash");
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const config_1 = require("../services/config");
exports.CONFIG_KEY = 'decorations.links.enable';
const linkDecoration = vscode.window.createTextEditorDecorationType({
    rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
    textDecoration: 'none',
    color: { id: 'textLink.foreground' },
    cursor: 'pointer',
});
const placeholderDecoration = vscode.window.createTextEditorDecorationType({
    rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
    textDecoration: 'none',
    color: { id: 'editorWarning.foreground' },
    cursor: 'pointer',
});
const updateDecorations = (areDecorationsEnabled, parser, workspace) => (editor) => {
    if (!editor || !areDecorationsEnabled()) {
        return;
    }
    const note = parser.parse(editor.document.uri, editor.document.getText());
    let linkRanges = [];
    let placeholderRanges = [];
    note.links.forEach(link => {
        const linkUri = workspace.resolveLink(note, link);
        if (foam_core_1.URI.isPlaceholder(linkUri)) {
            placeholderRanges.push(link.range);
        }
        else {
            linkRanges.push(link.range);
        }
    });
    editor.setDecorations(linkDecoration, linkRanges);
    editor.setDecorations(placeholderDecoration, placeholderRanges);
};
const feature = {
    activate: async (context, foamPromise) => {
        const areDecorationsEnabled = config_1.monitorFoamVsCodeConfig(exports.CONFIG_KEY);
        const foam = await foamPromise;
        let activeEditor = vscode.window.activeTextEditor;
        const debouncedUpdateDecorations = lodash_1.debounce(updateDecorations(areDecorationsEnabled, foam.services.parser, foam.workspace), 500);
        debouncedUpdateDecorations(activeEditor);
        context.subscriptions.push(areDecorationsEnabled, linkDecoration, placeholderDecoration, vscode.window.onDidChangeActiveTextEditor(editor => {
            activeEditor = editor;
            debouncedUpdateDecorations(activeEditor);
        }), vscode.workspace.onDidChangeTextDocument(event => {
            if (activeEditor && event.document === activeEditor.document) {
                debouncedUpdateDecorations(activeEditor);
            }
        }));
    },
};
exports.default = feature;
//# sourceMappingURL=document-decorator.js.map