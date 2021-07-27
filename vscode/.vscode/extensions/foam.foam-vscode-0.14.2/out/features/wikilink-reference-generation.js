"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const lodash_1 = require("lodash");
const vscode_1 = require("vscode");
const foam_core_1 = require("foam-core");
const utils_1 = require("../utils");
const settings_1 = require("../settings");
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.update-wikilinks', () => updateReferenceList(foam.workspace)), vscode_1.workspace.onWillSaveTextDocument(e => {
            if (e.document.languageId === 'markdown') {
                updateDocumentInNoteGraph(foam, e.document);
                e.waitUntil(updateReferenceList(foam.workspace));
            }
        }), vscode_1.languages.registerCodeLensProvider(utils_1.mdDocSelector, new WikilinkReferenceCodeLensProvider(foam.workspace)));
        // when a file is created as a result of peekDefinition
        // action on a wikilink, add definition update references
        foam.workspace.onDidAdd(_ => {
            let editor = vscode_1.window.activeTextEditor;
            if (!editor || !utils_1.isMdEditor(editor)) {
                return;
            }
            updateDocumentInNoteGraph(foam, editor.document);
            updateReferenceList(foam.workspace);
        });
    },
};
function updateDocumentInNoteGraph(foam, document) {
    foam.workspace.set(foam.services.parser.parse(document.uri, document.getText()));
}
async function createReferenceList(foam) {
    let editor = vscode_1.window.activeTextEditor;
    if (!editor || !utils_1.isMdEditor(editor)) {
        return;
    }
    let refs = await generateReferenceList(foam, editor.document);
    if (refs && refs.length) {
        await editor.edit(function (editBuilder) {
            if (editor) {
                const spacing = utils_1.hasEmptyTrailing(editor.document)
                    ? utils_1.docConfig.eol
                    : utils_1.docConfig.eol + utils_1.docConfig.eol;
                editBuilder.insert(new vscode_1.Position(editor.document.lineCount, 0), spacing + refs.join(utils_1.docConfig.eol));
            }
        });
    }
}
async function updateReferenceList(foam) {
    const editor = vscode_1.window.activeTextEditor;
    if (!editor || !utils_1.isMdEditor(editor)) {
        return;
    }
    utils_1.loadDocConfig();
    const doc = editor.document;
    const range = detectReferenceListRange(doc);
    if (!range) {
        await createReferenceList(foam);
    }
    else {
        const refs = generateReferenceList(foam, doc);
        // references must always be preceded by an empty line
        const spacing = doc.lineAt(range.start.line - 1).isEmptyOrWhitespace
            ? ''
            : utils_1.docConfig.eol;
        await editor.edit(editBuilder => {
            editBuilder.replace(range, spacing + refs.join(utils_1.docConfig.eol));
        });
    }
}
function generateReferenceList(foam, doc) {
    const wikilinkSetting = settings_1.getWikilinkDefinitionSetting();
    if (wikilinkSetting === settings_1.LinkReferenceDefinitionsSetting.off) {
        return [];
    }
    const note = foam.get(doc.uri);
    // Should never happen as `doc` is usually given by `editor.document`, which
    // binds to an opened note.
    if (!note) {
        console.warn(`Can't find note for URI ${doc.uri.path} before attempting to generate its markdown reference list`);
        return [];
    }
    const references = lodash_1.uniq(foam_core_1.createMarkdownReferences(foam, note.uri, wikilinkSetting === settings_1.LinkReferenceDefinitionsSetting.withExtensions).map(foam_core_1.stringifyMarkdownLinkReferenceDefinition));
    if (references.length) {
        return [
            foam_core_1.LINK_REFERENCE_DEFINITION_HEADER,
            ...references,
            foam_core_1.LINK_REFERENCE_DEFINITION_FOOTER,
        ];
    }
    return [];
}
/**
 * Find the range of existing reference list
 * @param doc
 */
function detectReferenceListRange(doc) {
    const fullText = doc.getText();
    const headerIndex = fullText.indexOf(foam_core_1.LINK_REFERENCE_DEFINITION_HEADER);
    const footerIndex = fullText.lastIndexOf(foam_core_1.LINK_REFERENCE_DEFINITION_FOOTER);
    if (headerIndex < 0) {
        return null;
    }
    const headerLine = fullText.substring(0, headerIndex).split(utils_1.docConfig.eol).length - 1;
    const footerLine = fullText.substring(0, footerIndex).split(utils_1.docConfig.eol).length - 1;
    if (headerLine >= footerLine) {
        return null;
    }
    return new vscode_1.Range(new vscode_1.Position(headerLine, 0), new vscode_1.Position(footerLine, foam_core_1.LINK_REFERENCE_DEFINITION_FOOTER.length));
}
class WikilinkReferenceCodeLensProvider {
    constructor(foam) {
        this.foam = foam;
    }
    provideCodeLenses(document, _) {
        utils_1.loadDocConfig();
        let range = detectReferenceListRange(document);
        if (!range) {
            return [];
        }
        const refs = generateReferenceList(this.foam, document);
        const oldRefs = utils_1.getText(range).replace(/\r?\n|\r/g, utils_1.docConfig.eol);
        const newRefs = refs.join(utils_1.docConfig.eol);
        let status = oldRefs === newRefs ? 'up to date' : 'out of date';
        return [
            new vscode_1.CodeLens(range, {
                arguments: [],
                title: `Link references (${status})`,
                command: '',
            }),
        ];
    }
}
exports.default = feature;
//# sourceMappingURL=wikilink-reference-generation.js.map