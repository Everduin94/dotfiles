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
const vscode_1 = require("vscode");
const fs = __importStar(require("fs"));
const foam_core_1 = require("foam-core");
const settings_1 = require("../settings");
const vsc_utils_1 = require("../utils/vsc-utils");
const feature = {
    activate: (context, foamPromise) => {
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.janitor', async () => janitor(await foamPromise)));
    },
};
async function janitor(foam) {
    try {
        const noOfFiles = foam.workspace.list().filter(Boolean).length;
        if (noOfFiles === 0) {
            return vscode_1.window.showInformationMessage("Foam Janitor didn't find any notes to clean up.");
        }
        const outcome = await vscode_1.window.withProgress({
            location: vscode_1.ProgressLocation.Notification,
            title: `Running Foam Janitor across ${noOfFiles} files!`,
        }, () => runJanitor(foam));
        if (!outcome.changedAnyFiles) {
            vscode_1.window.showInformationMessage(`Foam Janitor checked ${noOfFiles} files, and found nothing to clean up!`);
        }
        else {
            vscode_1.window.showInformationMessage(`Foam Janitor checked ${noOfFiles} files and updated ${outcome.updatedDefinitionListCount} out-of-date definition lists and added ${outcome.updatedHeadingCount} missing headings. Please check the changes before committing them into version control!`);
        }
    }
    catch (e) {
        vscode_1.window.showErrorMessage(`Foam Janitor attempted to clean your workspace but ran into an error. Please check that we didn't break anything before committing any changes to version control, and pass the following error message to the Foam team on GitHub issues:
    ${e.message}
    ${e.stack}`);
    }
}
async function runJanitor(foam) {
    const notes = foam.workspace
        .list()
        .filter(r => foam_core_1.URI.isMarkdownFile(r.uri));
    let updatedHeadingCount = 0;
    let updatedDefinitionListCount = 0;
    const dirtyTextDocuments = vscode_1.workspace.textDocuments.filter(textDocument => (textDocument.languageId === 'markdown' ||
        textDocument.languageId === 'mdx') &&
        textDocument.isDirty);
    const dirtyEditorsFileName = dirtyTextDocuments.map(dirtyTextDocument => dirtyTextDocument.uri.fsPath);
    const dirtyNotes = notes.filter(note => dirtyEditorsFileName.includes(foam_core_1.URI.toFsPath(note.uri)));
    const nonDirtyNotes = notes.filter(note => !dirtyEditorsFileName.includes(foam_core_1.URI.toFsPath(note.uri)));
    const wikilinkSetting = settings_1.getWikilinkDefinitionSetting();
    // Apply Text Edits to Non Dirty Notes using fs module just like CLI
    const fileWritePromises = nonDirtyNotes.map(note => {
        let heading = foam_core_1.generateHeading(note);
        if (heading) {
            updatedHeadingCount += 1;
        }
        let definitions = wikilinkSetting === settings_1.LinkReferenceDefinitionsSetting.off
            ? null
            : foam_core_1.generateLinkReferences(note, foam.workspace, wikilinkSetting === settings_1.LinkReferenceDefinitionsSetting.withExtensions);
        if (definitions) {
            updatedDefinitionListCount += 1;
        }
        if (!heading && !definitions) {
            return Promise.resolve();
        }
        // Apply Edits
        // Note: The ordering matters. Definitions need to be inserted
        // before heading, since inserting a heading changes line numbers below
        let text = note.source.text;
        text = definitions ? foam_core_1.applyTextEdit(text, definitions) : text;
        text = heading ? foam_core_1.applyTextEdit(text, heading) : text;
        return fs.promises.writeFile(foam_core_1.URI.toFsPath(note.uri), text);
    });
    await Promise.all(fileWritePromises);
    // Handle dirty editors in serial, as VSCode only allows
    // edits to be applied to active text editors
    for (const doc of dirtyTextDocuments) {
        const editor = await vscode_1.window.showTextDocument(doc);
        const note = dirtyNotes.find(n => foam_core_1.URI.toFsPath(n.uri) === editor.document.uri.fsPath);
        // Get edits
        const heading = foam_core_1.generateHeading(note);
        let definitions = wikilinkSetting === settings_1.LinkReferenceDefinitionsSetting.off
            ? null
            : foam_core_1.generateLinkReferences(note, foam.workspace, wikilinkSetting === settings_1.LinkReferenceDefinitionsSetting.withExtensions);
        if (heading || definitions) {
            // Apply Edits
            /* eslint-disable */
            await editor.edit(editBuilder => {
                // Note: The ordering matters. Definitions need to be inserted
                // before heading, since inserting a heading changes line numbers below
                if (definitions) {
                    updatedDefinitionListCount += 1;
                    const start = definitions.range.start;
                    const end = definitions.range.end;
                    const range = foam_core_1.Range.createFromPosition(start, end);
                    editBuilder.replace(vsc_utils_1.toVsCodeRange(range), definitions.newText);
                }
                if (heading) {
                    updatedHeadingCount += 1;
                    const start = heading.range.start;
                    editBuilder.replace(vsc_utils_1.toVsCodePosition(start), heading.newText);
                }
            });
            /* eslint-enable */
        }
    }
    return {
        updatedHeadingCount,
        updatedDefinitionListCount,
        changedAnyFiles: updatedHeadingCount + updatedDefinitionListCount,
    };
}
exports.default = feature;
//# sourceMappingURL=janitor.js.map