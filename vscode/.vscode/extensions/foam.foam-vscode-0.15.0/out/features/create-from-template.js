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
exports.createNoteForPlaceholderWikilink = exports.createNoteFromDailyNoteTemplate = exports.determineDefaultFilepath = exports.resolveFoamTemplateVariables = exports.substituteFoamVariables = exports.resolveFoamVariables = exports.UserCancelledOperation = void 0;
const foam_core_1 = require("foam-core");
const fs_1 = require("fs");
const path = __importStar(require("path"));
const path_1 = require("path");
const util_1 = require("util");
const vscode_1 = require("vscode");
const utils_1 = require("../utils");
const vsc_utils_1 = require("../utils/vsc-utils");
const template_frontmatter_parser_1 = require("../utils/template-frontmatter-parser");
const templatesDir = foam_core_1.URI.joinPath(vscode_1.workspace.workspaceFolders[0].uri, '.foam', 'templates');
class UserCancelledOperation extends Error {
    constructor(message) {
        super('UserCancelledOperation');
        if (message) {
            this.message = message;
        }
    }
}
exports.UserCancelledOperation = UserCancelledOperation;
const knownFoamVariables = new Set(['FOAM_TITLE', 'FOAM_SELECTED_TEXT']);
const wikilinkDefaultTemplateText = `# $\{1:$FOAM_TITLE}\n\n$0`;
const defaultTemplateDefaultText = `---
foam_template:
  name: New Note
  description: Foam's default new note template
---
# \${FOAM_TITLE}

\${FOAM_SELECTED_TEXT}
`;
const defaultTemplateUri = foam_core_1.URI.joinPath(templatesDir, 'new-note.md');
const dailyNoteTemplateUri = foam_core_1.URI.joinPath(templatesDir, 'daily-note.md');
const templateContent = `# \${1:$TM_FILENAME_BASE}

Welcome to Foam templates.

What you see in the heading is a placeholder
- it allows you to quickly move through positions of the new note by pressing TAB, e.g. to easily fill fields
- a placeholder optionally has a default value, which can be some text or, as in this case, a [variable](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variables)
  - when landing on a placeholder, the default value is already selected so you can easily replace it
- a placeholder can define a list of values, e.g.: \${2|one,two,three|}
- you can use variables even outside of placeholders, here is today's date: \${CURRENT_YEAR}/\${CURRENT_MONTH}/\${CURRENT_DATE}

For a full list of features see [the VS Code snippets page](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_snippet-syntax).

## To get started

1. edit this file to create the shape new notes from this template will look like
2. create a note from this template by running the \`Foam: Create New Note From Template\` command
`;
async function templateMetadata(templateUri) {
    const contents = await vscode_1.workspace.fs
        .readFile(vsc_utils_1.toVsCodeUri(templateUri))
        .then(bytes => bytes.toString());
    const [templateMetadata] = template_frontmatter_parser_1.extractFoamTemplateFrontmatterMetadata(contents);
    return templateMetadata;
}
async function getTemplates() {
    const templates = await vscode_1.workspace.findFiles('.foam/templates/**.md', null);
    return templates;
}
async function offerToCreateTemplate() {
    const response = await vscode_1.window.showQuickPick(['Yes', 'No'], {
        placeHolder: 'No templates available. Would you like to create one instead?',
    });
    if (response === 'Yes') {
        vscode_1.commands.executeCommand('foam-vscode.create-new-template');
        return;
    }
}
function findFoamVariables(templateText) {
    const regex = /\$(FOAM_[_a-zA-Z0-9]*)|\${(FOAM_[[_a-zA-Z0-9]*)}/g;
    var matches = [];
    const output = [];
    while ((matches = regex.exec(templateText))) {
        output.push(matches[1] || matches[2]);
    }
    const uniqVariables = [...new Set(output)];
    const knownVariables = uniqVariables.filter(x => knownFoamVariables.has(x));
    return knownVariables;
}
async function resolveFoamTitle() {
    const title = await vscode_1.window.showInputBox({
        prompt: `Enter a title for the new note`,
        value: 'Title of my New Note',
        validateInput: value => value.trim().length === 0 ? 'Please enter a title' : undefined,
    });
    if (title === undefined) {
        throw new UserCancelledOperation();
    }
    return title;
}
function resolveFoamSelectedText() {
    var _a, _b;
    return (_b = (_a = findSelectionContent()) === null || _a === void 0 ? void 0 : _a.content) !== null && _b !== void 0 ? _b : '';
}
class Resolver {
    constructor() {
        this.promises = new Map();
    }
    resolve(name, givenValues) {
        if (givenValues.has(name)) {
            this.promises.set(name, Promise.resolve(givenValues.get(name)));
        }
        else if (!this.promises.has(name)) {
            switch (name) {
                case 'FOAM_TITLE':
                    this.promises.set(name, resolveFoamTitle());
                    break;
                case 'FOAM_SELECTED_TEXT':
                    this.promises.set(name, Promise.resolve(resolveFoamSelectedText()));
                    break;
                default:
                    this.promises.set(name, Promise.resolve(name));
                    break;
            }
        }
        const result = this.promises.get(name);
        return result;
    }
}
async function resolveFoamVariables(variables, givenValues) {
    const resolver = new Resolver();
    const promises = variables.map(async (variable) => Promise.resolve([variable, await resolver.resolve(variable, givenValues)]));
    const results = await Promise.all(promises);
    const valueByName = new Map();
    results.forEach(([variable, value]) => {
        valueByName.set(variable, value);
    });
    return valueByName;
}
exports.resolveFoamVariables = resolveFoamVariables;
function substituteFoamVariables(templateText, givenValues) {
    givenValues.forEach((value, variable) => {
        const regex = new RegExp(
        // Matches a limited subset of the the TextMate variable syntax:
        //  ${VARIABLE}  OR   $VARIABLE
        `\\\${${variable}}|\\$${variable}(\\W|$)`, 
        // The latter is more complicated, since it needs to avoid replacing
        // longer variable names with the values of variables that are
        // substrings of the longer ones (e.g. `$FOO` and `$FOOBAR`. If you
        // replace $FOO first, and aren't careful, you replace the first
        // characters of `$FOOBAR`)
        'g' // 'g' => Global replacement (i.e. not just the first instance)
        );
        templateText = templateText.replace(regex, `${value}$1`);
    });
    return templateText;
}
exports.substituteFoamVariables = substituteFoamVariables;
function sortTemplatesMetadata(t1, t2) {
    // Sort by name's existence, then name, then path
    if (t1.get('name') === undefined && t2.get('name') !== undefined) {
        return 1;
    }
    if (t1.get('name') !== undefined && t2.get('name') === undefined) {
        return -1;
    }
    const pathSortOrder = t1
        .get('templatePath')
        .localeCompare(t2.get('templatePath'));
    if (t1.get('name') === undefined && t2.get('name') === undefined) {
        return pathSortOrder;
    }
    const nameSortOrder = t1.get('name').localeCompare(t2.get('name'));
    return nameSortOrder || pathSortOrder;
}
async function askUserForTemplate() {
    const templates = await getTemplates();
    if (templates.length === 0) {
        return offerToCreateTemplate();
    }
    const templatesMetadata = (await Promise.all(templates.map(async (templateUri) => {
        const metadata = await templateMetadata(templateUri);
        metadata.set('templatePath', path.basename(templateUri.path));
        return metadata;
    }))).sort(sortTemplatesMetadata);
    const items = await Promise.all(templatesMetadata.map(metadata => {
        const label = metadata.get('name') || metadata.get('templatePath');
        const description = metadata.get('name')
            ? metadata.get('templatePath')
            : null;
        const detail = metadata.get('description');
        const item = {
            label: label,
            description: description,
            detail: detail,
        };
        Object.keys(item).forEach(key => {
            if (!item[key]) {
                delete item[key];
            }
        });
        return item;
    }));
    return await vscode_1.window.showQuickPick(items, {
        placeHolder: 'Select a template to use.',
    });
}
async function askUserForFilepathConfirmation(defaultFilepath, defaultFilename) {
    const fsPath = foam_core_1.URI.toFsPath(defaultFilepath);
    return await vscode_1.window.showInputBox({
        prompt: `Enter the filename for the new note`,
        value: fsPath,
        valueSelection: [fsPath.length - defaultFilename.length, fsPath.length - 3],
        validateInput: value => value.trim().length === 0
            ? 'Please enter a value'
            : fs_1.existsSync(value)
                ? 'File already exists'
                : undefined,
    });
}
function appendSnippetVariableUsage(templateText, variable) {
    if (templateText.endsWith('\n')) {
        return `${templateText}\${${variable}}\n`;
    }
    else {
        return `${templateText}\n\${${variable}}`;
    }
}
async function resolveFoamTemplateVariables(templateText, extraVariablesToResolve = new Set(), givenValues = new Map()) {
    const variablesInTemplate = findFoamVariables(templateText.toString());
    const variables = variablesInTemplate.concat(...extraVariablesToResolve);
    const uniqVariables = [...new Set(variables)];
    const resolvedValues = await resolveFoamVariables(uniqVariables, givenValues);
    if (resolvedValues.get('FOAM_SELECTED_TEXT') &&
        !variablesInTemplate.includes('FOAM_SELECTED_TEXT')) {
        templateText = appendSnippetVariableUsage(templateText, 'FOAM_SELECTED_TEXT');
        variablesInTemplate.push('FOAM_SELECTED_TEXT');
        variables.push('FOAM_SELECTED_TEXT');
        uniqVariables.push('FOAM_SELECTED_TEXT');
    }
    const subbedText = substituteFoamVariables(templateText.toString(), resolvedValues);
    return [resolvedValues, subbedText];
}
exports.resolveFoamTemplateVariables = resolveFoamTemplateVariables;
async function writeTemplate(templateSnippet, filepath, viewColumn = vscode_1.ViewColumn.Active) {
    await vscode_1.workspace.fs.writeFile(vsc_utils_1.toVsCodeUri(filepath), new util_1.TextEncoder().encode(''));
    await utils_1.focusNote(filepath, true, viewColumn);
    await vscode_1.window.activeTextEditor.insertSnippet(templateSnippet);
}
function currentDirectoryFilepath(filename) {
    var _a, _b;
    const activeFile = (_b = (_a = vscode_1.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document) === null || _b === void 0 ? void 0 : _b.uri.path;
    const currentDir = activeFile !== undefined
        ? foam_core_1.URI.parse(path.dirname(activeFile))
        : vscode_1.workspace.workspaceFolders[0].uri;
    return foam_core_1.URI.joinPath(currentDir, filename);
}
function findSelectionContent() {
    const editor = vscode_1.window.activeTextEditor;
    if (editor === undefined) {
        return undefined;
    }
    const document = editor.document;
    const selection = editor.selection;
    if (!document || selection.isEmpty) {
        return undefined;
    }
    return {
        document,
        selection,
        content: document.getText(selection),
    };
}
async function replaceSelectionWithWikiLink(document, newNoteFile, selection) {
    const newNoteTitle = foam_core_1.URI.getFileNameWithoutExtension(newNoteFile);
    const originatingFileEdit = new vscode_1.WorkspaceEdit();
    originatingFileEdit.replace(document.uri, selection, `[[${newNoteTitle}]]`);
    await vscode_1.workspace.applyEdit(originatingFileEdit);
}
function resolveFilepathAttribute(filepath) {
    return path_1.isAbsolute(filepath)
        ? foam_core_1.URI.file(filepath)
        : foam_core_1.URI.joinPath(vscode_1.workspace.workspaceFolders[0].uri, filepath);
}
function determineDefaultFilepath(resolvedValues, templateMetadata, fallbackURI = undefined) {
    let defaultFilepath;
    if (templateMetadata.get('filepath')) {
        defaultFilepath = resolveFilepathAttribute(templateMetadata.get('filepath'));
    }
    else if (fallbackURI) {
        return fallbackURI;
    }
    else {
        const defaultSlug = resolvedValues.get('FOAM_TITLE') || 'New Note';
        defaultFilepath = currentDirectoryFilepath(`${defaultSlug}.md`);
    }
    return defaultFilepath;
}
exports.determineDefaultFilepath = determineDefaultFilepath;
/**
 * Creates a daily note from the daily note template.
 * @param filepathFallbackURI the URI to use if the template does not specify the `filepath` metadata attribute. This is configurable by the caller for backwards compatibility purposes.
 * @param templateFallbackText the template text to use if daily-note.md template does not exist. This is configurable by the caller for backwards compatibility purposes.
 */
async function createNoteFromDailyNoteTemplate(filepathFallbackURI, templateFallbackText) {
    return await createNoteFromDefaultTemplate(new Map(), new Set(['FOAM_SELECTED_TEXT']), dailyNoteTemplateUri, filepathFallbackURI, templateFallbackText);
}
exports.createNoteFromDailyNoteTemplate = createNoteFromDailyNoteTemplate;
/**
 * Creates a new note when following a placeholder wikilink using the default template.
 * @param wikilinkPlaceholder the placeholder value from the wikilink. (eg. `[[Hello Joe]]` -> `Hello Joe`)
 * @param filepathFallbackURI the URI to use if the template does not specify the `filepath` metadata attribute. This is configurable by the caller for backwards compatibility purposes.
 */
async function createNoteForPlaceholderWikilink(wikilinkPlaceholder, filepathFallbackURI) {
    return await createNoteFromDefaultTemplate(new Map().set('FOAM_TITLE', wikilinkPlaceholder), new Set(['FOAM_TITLE', 'FOAM_SELECTED_TEXT']), defaultTemplateUri, filepathFallbackURI, wikilinkDefaultTemplateText);
}
exports.createNoteForPlaceholderWikilink = createNoteForPlaceholderWikilink;
/**
 * Creates a new note using the default note template.
 * @param givenValues already resolved values of Foam template variables. These are used instead of resolving the Foam template variables.
 * @param extraVariablesToResolve Foam template variables to resolve, in addition to those mentioned in the template.
 * @param templateUri the URI of the template to use.
 * @param filepathFallbackURI the URI to use if the template does not specify the `filepath` metadata attribute. This is configurable by the caller for backwards compatibility purposes.
 * @param templateFallbackText the template text to use the default note template does not exist. This is configurable by the caller for backwards compatibility purposes.
 */
async function createNoteFromDefaultTemplate(givenValues = new Map(), extraVariablesToResolve = new Set([
    'FOAM_TITLE',
    'FOAM_SELECTED_TEXT',
]), templateUri = defaultTemplateUri, filepathFallbackURI = undefined, templateFallbackText = defaultTemplateDefaultText) {
    var _a;
    const templateText = fs_1.existsSync(foam_core_1.URI.toFsPath(templateUri))
        ? await vscode_1.workspace.fs
            .readFile(vsc_utils_1.toVsCodeUri(templateUri))
            .then(bytes => bytes.toString())
        : templateFallbackText;
    const selectedContent = findSelectionContent();
    let resolvedValues, templateWithResolvedVariables;
    try {
        [
            resolvedValues,
            templateWithResolvedVariables,
        ] = await resolveFoamTemplateVariables(templateText, extraVariablesToResolve, givenValues.set('FOAM_SELECTED_TEXT', (_a = selectedContent === null || selectedContent === void 0 ? void 0 : selectedContent.content) !== null && _a !== void 0 ? _a : ''));
    }
    catch (err) {
        if (err instanceof UserCancelledOperation) {
            return;
        }
        else {
            throw err;
        }
    }
    const [templateMetadata, templateWithFoamFrontmatterRemoved,] = template_frontmatter_parser_1.extractFoamTemplateFrontmatterMetadata(templateWithResolvedVariables);
    const templateSnippet = new vscode_1.SnippetString(templateWithFoamFrontmatterRemoved);
    const defaultFilepath = determineDefaultFilepath(resolvedValues, templateMetadata, filepathFallbackURI);
    const defaultFilename = path.basename(defaultFilepath.path);
    let filepath = defaultFilepath;
    if (fs_1.existsSync(foam_core_1.URI.toFsPath(filepath))) {
        const newFilepath = await askUserForFilepathConfirmation(defaultFilepath, defaultFilename);
        if (newFilepath === undefined) {
            return;
        }
        filepath = foam_core_1.URI.file(newFilepath);
    }
    await writeTemplate(templateSnippet, filepath, selectedContent ? vscode_1.ViewColumn.Beside : vscode_1.ViewColumn.Active);
    if (selectedContent !== undefined) {
        await replaceSelectionWithWikiLink(selectedContent.document, filepath, selectedContent.selection);
    }
}
async function createNoteFromTemplate(templateFilename) {
    var _a;
    const selectedTemplate = await askUserForTemplate();
    if (selectedTemplate === undefined) {
        return;
    }
    templateFilename =
        selectedTemplate.description ||
            selectedTemplate.label;
    const templateUri = foam_core_1.URI.joinPath(templatesDir, templateFilename);
    const templateText = await vscode_1.workspace.fs
        .readFile(vsc_utils_1.toVsCodeUri(templateUri))
        .then(bytes => bytes.toString());
    const selectedContent = findSelectionContent();
    let resolvedValues, templateWithResolvedVariables;
    try {
        [
            resolvedValues,
            templateWithResolvedVariables,
        ] = await resolveFoamTemplateVariables(templateText, new Set(['FOAM_SELECTED_TEXT']), new Map().set('FOAM_SELECTED_TEXT', (_a = selectedContent === null || selectedContent === void 0 ? void 0 : selectedContent.content) !== null && _a !== void 0 ? _a : ''));
    }
    catch (err) {
        if (err instanceof UserCancelledOperation) {
            return;
        }
        else {
            throw err;
        }
    }
    const [templateMetadata, templateWithFoamFrontmatterRemoved,] = template_frontmatter_parser_1.extractFoamTemplateFrontmatterMetadata(templateWithResolvedVariables);
    const templateSnippet = new vscode_1.SnippetString(templateWithFoamFrontmatterRemoved);
    const defaultFilepath = determineDefaultFilepath(resolvedValues, templateMetadata);
    const defaultFilename = path.basename(defaultFilepath.path);
    const filepath = await askUserForFilepathConfirmation(defaultFilepath, defaultFilename);
    if (filepath === undefined) {
        return;
    }
    const filepathURI = foam_core_1.URI.file(filepath);
    await writeTemplate(templateSnippet, filepathURI, selectedContent ? vscode_1.ViewColumn.Beside : vscode_1.ViewColumn.Active);
    if (selectedContent !== undefined) {
        await replaceSelectionWithWikiLink(selectedContent.document, filepathURI, selectedContent.selection);
    }
}
async function createNewTemplate() {
    const defaultFilename = 'new-template.md';
    const defaultTemplate = foam_core_1.URI.joinPath(templatesDir, defaultFilename);
    const fsPath = foam_core_1.URI.toFsPath(defaultTemplate);
    const filename = await vscode_1.window.showInputBox({
        prompt: `Enter the filename for the new template`,
        value: fsPath,
        valueSelection: [fsPath.length - defaultFilename.length, fsPath.length - 3],
        validateInput: value => value.trim().length === 0
            ? 'Please enter a value'
            : fs_1.existsSync(value)
                ? 'File already exists'
                : undefined,
    });
    if (filename === undefined) {
        return;
    }
    const filenameURI = foam_core_1.URI.file(filename);
    await vscode_1.workspace.fs.writeFile(vsc_utils_1.toVsCodeUri(filenameURI), new util_1.TextEncoder().encode(templateContent));
    await utils_1.focusNote(filenameURI, false);
}
const feature = {
    activate: (context) => {
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.create-note-from-template', createNoteFromTemplate));
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.create-note-from-default-template', createNoteFromDefaultTemplate));
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.create-new-template', createNewTemplate));
    },
};
exports.default = feature;
//# sourceMappingURL=create-from-template.js.map