"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = void 0;
const vscode = require("vscode");
const API_1 = require("./API");
const BacklinksTreeDataProvider_1 = require("./BacklinksTreeDataProvider");
const MarkdownDefinitionProvider_1 = require("./MarkdownDefinitionProvider");
const MarkdownReferenceProvider_1 = require("./MarkdownReferenceProvider");
const MarkdownFileCompletionItemProvider_1 = require("./MarkdownFileCompletionItemProvider");
const NoteWorkspace_1 = require("./NoteWorkspace");
const NoteParser_1 = require("./NoteParser");
const Ref_1 = require("./Ref");
const MarkdownRenderingPlugin_1 = require("./MarkdownRenderingPlugin");
// import { debug } from 'util';
// import { create } from 'domain';
function activate(context) {
    // console.debug('vscode-markdown-notes.activate');
    const ds = NoteWorkspace_1.NoteWorkspace.DOCUMENT_SELECTOR;
    NoteWorkspace_1.NoteWorkspace.overrideMarkdownWordPattern(); // still nec to get ../ to trigger suggestions in `relativePaths` mode
    context.subscriptions.push(vscode.languages.registerCompletionItemProvider(ds, new MarkdownFileCompletionItemProvider_1.MarkdownFileCompletionItemProvider()));
    context.subscriptions.push(vscode.languages.registerDefinitionProvider(ds, new MarkdownDefinitionProvider_1.MarkdownDefinitionProvider()));
    context.subscriptions.push(vscode.languages.registerReferenceProvider(ds, new MarkdownReferenceProvider_1.MarkdownReferenceProvider()));
    vscode.workspace.onDidChangeTextDocument((e) => {
        NoteParser_1.NoteParser.updateCacheFor(e.document.uri.fsPath);
        if (NoteWorkspace_1.NoteWorkspace.triggerSuggestOnReplacement()) {
            // See discussion on https://github.com/kortina/vscode-markdown-notes/pull/69/
            const shouldSuggest = e.contentChanges.some((change) => {
                const ref = Ref_1.getRefAt(e.document, change.range.end);
                return ref.type != Ref_1.RefType.Null && change.rangeLength > ref.word.length;
            });
            if (shouldSuggest) {
                vscode.commands.executeCommand('editor.action.triggerSuggest');
            }
        }
    });
    let newNoteDisposable = vscode.commands.registerCommand('vscodeMarkdownNotes.newNote', NoteWorkspace_1.NoteWorkspace.newNote);
    context.subscriptions.push(newNoteDisposable);
    let newNoteFromSelectionDisposable = vscode.commands.registerCommand('vscodeMarkdownNotes.newNoteFromSelection', NoteWorkspace_1.NoteWorkspace.newNoteFromSelection);
    context.subscriptions.push(newNoteFromSelectionDisposable);
    let d = vscode.commands.registerCommand('vscodeMarkdownNotes.notesForWikiLink', API_1.API.notesForWikiLink);
    context.subscriptions.push(d);
    // parse the tags from every file in the workspace
    NoteParser_1.NoteParser.hydrateCache();
    const backlinksTreeDataProvider = new BacklinksTreeDataProvider_1.BacklinksTreeDataProvider(vscode.workspace.rootPath || null);
    vscode.window.onDidChangeActiveTextEditor(() => backlinksTreeDataProvider.reload());
    const treeView = vscode.window.createTreeView('vscodeMarkdownNotesBacklinks', {
        treeDataProvider: backlinksTreeDataProvider,
        showCollapseAll: true
    });
    // See: https://code.visualstudio.com/api/extension-guides/markdown-extension
    // For more information on how this works.
    try {
        return {
            extendMarkdownIt(md) {
                return md.use(MarkdownRenderingPlugin_1.pluginSettings());
            },
        };
    }
    catch (err) {
        console.error(`Skipped Markdown extension: markdown-it-wikilinks\nBecause:\n${err}`);
    }
}
exports.activate = activate;
//# sourceMappingURL=extension.js.map