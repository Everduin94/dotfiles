"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NoteWorkspace = exports.PipedWikiLinksSyntax = exports.SlugifyMethod = exports.foo = void 0;
const vscode = require("vscode");
const path_1 = require("path");
const fs_1 = require("fs");
const findNonIgnoredFiles_1 = require("./findNonIgnoredFiles");
const GithubSlugger = require('github-slugger');
const SLUGGER = new GithubSlugger();
exports.foo = () => {
    return 1;
};
var NoteCompletionConvention;
(function (NoteCompletionConvention) {
    NoteCompletionConvention["rawFilename"] = "rawFilename";
    NoteCompletionConvention["noExtension"] = "noExtension";
    NoteCompletionConvention["toSpaces"] = "toSpaces";
})(NoteCompletionConvention || (NoteCompletionConvention = {}));
var WorkspaceFilenameConvention;
(function (WorkspaceFilenameConvention) {
    WorkspaceFilenameConvention["uniqueFilenames"] = "uniqueFilenames";
    WorkspaceFilenameConvention["relativePaths"] = "relativePaths";
})(WorkspaceFilenameConvention || (WorkspaceFilenameConvention = {}));
var SlugifyCharacter;
(function (SlugifyCharacter) {
    SlugifyCharacter["dash"] = "-";
    SlugifyCharacter["underscore"] = "_";
    SlugifyCharacter["fullwidthDash"] = "\uFF0D";
    SlugifyCharacter["fullwidthUnderscore"] = "\uFF3F";
    SlugifyCharacter["none"] = "NONE";
})(SlugifyCharacter || (SlugifyCharacter = {}));
var SlugifyMethod;
(function (SlugifyMethod) {
    SlugifyMethod["github"] = "github-slugger";
    SlugifyMethod["classic"] = "classic";
})(SlugifyMethod = exports.SlugifyMethod || (exports.SlugifyMethod = {}));
var PipedWikiLinksSyntax;
(function (PipedWikiLinksSyntax) {
    PipedWikiLinksSyntax["fileDesc"] = "file|desc";
    PipedWikiLinksSyntax["descFile"] = "desc|file";
})(PipedWikiLinksSyntax = exports.PipedWikiLinksSyntax || (exports.PipedWikiLinksSyntax = {}));
var PreviewLabelStyling;
(function (PreviewLabelStyling) {
    PreviewLabelStyling["brackets"] = "[[label]]";
    PreviewLabelStyling["bracket"] = "[label]";
    PreviewLabelStyling["none"] = "label";
})(PreviewLabelStyling || (PreviewLabelStyling = {}));
// This class contains:
// 1. an interface to some of the basic user configurable settings or this extension
// 2. command for creating a New Note
// 3. some other bootstrapping
let NoteWorkspace = /** @class */ (() => {
    class NoteWorkspace {
        static cfg() {
            let c = vscode.workspace.getConfiguration('vscodeMarkdownNotes');
            return {
                createNoteOnGoToDefinitionWhenMissing: c.get('createNoteOnGoToDefinitionWhenMissing'),
                defaultFileExtension: c.get('defaultFileExtension'),
                noteCompletionConvention: c.get('noteCompletionConvention'),
                slugifyCharacter: c.get('slugifyCharacter'),
                slugifyMethod: c.get('slugifyMethod'),
                workspaceFilenameConvention: c.get('workspaceFilenameConvention'),
                newNoteTemplate: c.get('newNoteTemplate'),
                newNoteFromSelectionReplacementTemplate: c.get('newNoteFromSelectionReplacementTemplate'),
                lowercaseNewNoteFilenames: c.get('lowercaseNewNoteFilenames'),
                compileSuggestionDetails: c.get('compileSuggestionDetails'),
                triggerSuggestOnReplacement: c.get('triggerSuggestOnReplacement'),
                allowPipedWikiLinks: c.get('allowPipedWikiLinks'),
                pipedWikiLinksSyntax: c.get('pipedWikiLinksSyntax'),
                pipedWikiLinksSeparator: c.get('pipedWikiLinksSeparator'),
                newNoteDirectory: c.get('newNoteDirectory'),
                previewLabelStyling: c.get('previewLabelStyling'),
                previewShowFileExtension: c.get('previewShowFileExtension'),
            };
        }
        static slugifyChar() {
            return this.cfg().slugifyCharacter;
        }
        static slugifyMethod() {
            return this.cfg().slugifyMethod;
        }
        static defaultFileExtension() {
            return this.cfg().defaultFileExtension;
        }
        static newNoteTemplate() {
            return this.cfg().newNoteTemplate;
        }
        static newNoteFromSelectionReplacementTemplate() {
            return this.cfg().newNoteFromSelectionReplacementTemplate;
        }
        static lowercaseNewNoteFilenames() {
            return this.cfg().lowercaseNewNoteFilenames;
        }
        static triggerSuggestOnReplacement() {
            return this.cfg().triggerSuggestOnReplacement;
        }
        static allowPipedWikiLinks() {
            return this.cfg().allowPipedWikiLinks;
        }
        static pipedWikiLinksSyntax() {
            return this.cfg().pipedWikiLinksSyntax;
        }
        static pipedWikiLinksSeparator() {
            return this.cfg().pipedWikiLinksSeparator;
        }
        static newNoteDirectory() {
            return this.cfg().newNoteDirectory;
        }
        static previewLabelStyling() {
            return this.cfg().previewLabelStyling;
        }
        static previewShowFileExtension() {
            return this.cfg().previewShowFileExtension;
        }
        static rxTag() {
            // NB: MUST have g flag to match multiple words per line
            return new RegExp(this._rxTag, 'gui');
        }
        static rxBeginTag() {
            return new RegExp(this._rxBeginTag, 'gui');
        }
        static rxWikiLink() {
            // NB: MUST have g flag to match multiple words per line
            this._rxWikiLink = this._rxWikiLink.replace(/sep/g, NoteWorkspace.pipedWikiLinksSeparator());
            return new RegExp(this._rxWikiLink, 'gi');
        }
        static rxTitle() {
            return new RegExp(this._rxTitle, 'gi');
        }
        static rxMarkdownWordPattern() {
            return new RegExp(this._rxMarkdownWordPattern, 'u');
        }
        static rxFileExtensions() {
            // return noteName.replace(/\.(md|markdown|mdx|fountain)$/i, '');
            return new RegExp(this._rxFileExtensions, 'i');
        }
        static rxMarkdownHyperlink() {
            return new RegExp(this._rxMarkdownHyperlink, 'gi');
        }
        static wikiLinkCompletionForConvention(uri, fromDocument) {
            if (this.useUniqueFilenames()) {
                let filename = path_1.basename(uri.fsPath);
                let c = this.cfg().noteCompletionConvention;
                return this._wikiLinkCompletionForConvention(c, filename);
            }
            else {
                let toPath = uri.fsPath;
                let fromDir = path_1.dirname(fromDocument.uri.fsPath.toString());
                let rel = path_1.normalize(path_1.relative(fromDir, toPath));
                return rel;
            }
        }
        static _wikiLinkCompletionForConvention(convention, filename) {
            if (convention == 'toSpaces') {
                return this.stripExtension(filename).replace(/[-_]+/g, ' ');
            }
            else if (convention == 'noExtension') {
                return this.stripExtension(filename);
            }
            else {
                return filename;
            }
        }
        static useUniqueFilenames() {
            // return false;
            return this.cfg().workspaceFilenameConvention == 'uniqueFilenames';
        }
        static createNoteOnGoToDefinitionWhenMissing() {
            return !!this.cfg().createNoteOnGoToDefinitionWhenMissing;
        }
        static compileSuggestionDetails() {
            return this.cfg().compileSuggestionDetails;
        }
        static stripExtension(noteName) {
            return noteName.replace(NoteWorkspace.rxFileExtensions(), '');
        }
        static normalizeNoteNameForFuzzyMatch(noteName) {
            // remove the brackets:
            let n = noteName.replace(/[\[\]]/g, '');
            // remove the filepath:
            // NB: this may not work with relative paths?
            n = path_1.basename(n);
            // remove the extension:
            n = this.stripExtension(n);
            // slugify (to normalize spaces)
            n = this.slugifyTitle(n);
            return n;
        }
        static cleanPipedWikiLink(noteName) {
            // Check whether or not we should remove the description
            if (NoteWorkspace.allowPipedWikiLinks()) {
                let separator = NoteWorkspace.pipedWikiLinksSeparator();
                let captureGroup = '[^\\[' + separator + ']+';
                let regex;
                if (NoteWorkspace.pipedWikiLinksSyntax() == 'file|desc') {
                    // Should capture the "|desc" at the end of a wiki-link
                    regex = new RegExp(separator + captureGroup + '$');
                }
                else {
                    // Should capture the "desc|" at the beginning of a wiki-link
                    regex = new RegExp('^' + captureGroup + separator);
                }
                noteName = noteName.replace(regex, ''); // Remove description from the end
                return noteName;
                // If piped wiki-links aren't used, don't alter the note name.
            }
            else {
                return noteName;
            }
        }
        static normalizeNoteNameForFuzzyMatchText(noteName) {
            // remove the brackets:
            let n = noteName.replace(/[\[\]]/g, '');
            // remove the potential description:
            n = this.cleanPipedWikiLink(n);
            // remove the extension:
            n = this.stripExtension(n);
            // slugify (to normalize spaces)
            n = this.slugifyTitle(n);
            return n;
        }
        // compare a hyperlink to a filename for a fuzzy match.
        // `left` is the ref word, `right` is the file name
        static noteNamesFuzzyMatchHyperlinks(left, right) {
            // strip markdown link syntax; remove the [description]
            left = left.replace(/\[[^\[\]]*\]/g, '');
            // and the () surrounding the link
            left = left.replace(/\(|\)/g, '');
            return (this.normalizeNoteNameForFuzzyMatch(left).toLowerCase() ==
                this.normalizeNoteNameForFuzzyMatchText(right).toLowerCase());
        }
        // Compare 2 wiki-links for a fuzzy match.
        // In general, we expect
        // `left` to be fsPath
        // `right` to be the ref word [[wiki-link]]
        static noteNamesFuzzyMatch(left, right) {
            return (this.normalizeNoteNameForFuzzyMatch(left).toLowerCase() ==
                this.normalizeNoteNameForFuzzyMatchText(right).toLowerCase());
        }
        static noteNamesFuzzyMatchText(left, right) {
            return (this.normalizeNoteNameForFuzzyMatchText(left).toLowerCase() ==
                this.normalizeNoteNameForFuzzyMatchText(right).toLowerCase());
        }
        static cleanTitle(title) {
            const caseAdjustedTitle = this.lowercaseNewNoteFilenames() ? title.toLowerCase() : title;
            // removing trailing slug chars
            return caseAdjustedTitle.replace(/[-_－＿ ]*$/g, '');
        }
        static slugifyClassic(title) {
            let t = this.slugifyChar() == 'NONE'
                ? title
                : title.replace(/[!"\#$%&'()*+,\-./:;<=>?@\[\\\]^_‘{|}~\s]+/gi, this.slugifyChar()); // punctuation and whitespace to hyphens (or underscores)
            return this.cleanTitle(t);
        }
        static slugifyGithub(title) {
            SLUGGER.reset(); // otherwise it will increment repeats with -1 -2 -3 etc.
            return SLUGGER.slug(title);
        }
        static slugifyTitle(title) {
            if (this.slugifyMethod() == SlugifyMethod.classic) {
                return this.slugifyClassic(title);
            }
            else {
                return this.slugifyGithub(title);
            }
        }
        static noteFileNameFromTitle(title) {
            let t = this.slugifyTitle(title);
            return t.match(this.rxFileExtensions()) ? t : `${t}.${this.defaultFileExtension()}`;
        }
        static showNewNoteInputBox() {
            return vscode.window.showInputBox({
                prompt: "Enter a 'Title Case Name' to create `title-case-name.md` with '# Title Case Name' at the top.",
                value: '',
            });
        }
        static newNote(context) {
            // console.debug('newNote');
            const inputBoxPromise = NoteWorkspace.showNewNoteInputBox();
            inputBoxPromise.then((noteName) => {
                if (noteName == null || !noteName || noteName.replace(/\s+/g, '') == '') {
                    // console.debug('Abort: noteName was empty.');
                    return false;
                }
                const { filepath, fileAlreadyExists } = NoteWorkspace.createNewNoteFile(noteName);
                // open the file:
                vscode.window
                    .showTextDocument(vscode.Uri.file(filepath), {
                    preserveFocus: false,
                    preview: false,
                })
                    .then(() => {
                    // if we created a new file, place the selection at the end of the last line of the template
                    if (!fileAlreadyExists) {
                        let editor = vscode.window.activeTextEditor;
                        if (editor) {
                            const lineNumber = editor.document.lineCount;
                            const range = editor.document.lineAt(lineNumber - 1).range;
                            editor.selection = new vscode.Selection(range.end, range.end);
                            editor.revealRange(range);
                        }
                    }
                });
            }, (err) => {
                vscode.window.showErrorMessage('Error creating new note.');
            });
        }
        static newNoteFromSelection(context) {
            const originEditor = vscode.window.activeTextEditor;
            if (!originEditor) {
                // console.debug('Abort: no active editor');
                return;
            }
            const { selection } = originEditor;
            const noteContents = originEditor.document.getText(selection);
            const originSelectionRange = new vscode.Range(selection.start, selection.end);
            if (noteContents === '') {
                vscode.window.showErrorMessage('Error creating note from selection: selection is empty.');
                return;
            }
            // console.debug('newNote');
            const inputBoxPromise = NoteWorkspace.showNewNoteInputBox();
            inputBoxPromise.then((noteName) => {
                if (noteName == null || !noteName || noteName.replace(/\s+/g, '') == '') {
                    // console.debug('Abort: noteName was empty.');
                    return false;
                }
                const { filepath, fileAlreadyExists } = NoteWorkspace.createNewNoteFile(noteName);
                const destinationUri = vscode.Uri.file(filepath);
                // open the file:
                vscode.window
                    .showTextDocument(destinationUri, {
                    preserveFocus: false,
                    preview: false,
                })
                    .then(() => {
                    if (!fileAlreadyExists) {
                        const destinationEditor = vscode.window.activeTextEditor;
                        if (destinationEditor) {
                            // Place the selection at the end of the last line of the template
                            const lineNumber = destinationEditor.document.lineCount;
                            const range = destinationEditor.document.lineAt(lineNumber - 1).range;
                            destinationEditor.selection = new vscode.Selection(range.end, range.end);
                            destinationEditor.revealRange(range);
                            // Insert the selected content in to the new file
                            destinationEditor.edit((edit) => {
                                if (destinationEditor) {
                                    if (range.start.character === range.end.character) {
                                        edit.insert(destinationEditor.selection.end, noteContents);
                                    }
                                    else {
                                        // If the last line is not empty, insert the note contents on a new line
                                        edit.insert(destinationEditor.selection.end, '\n\n' + noteContents);
                                    }
                                }
                            });
                            // Replace the selected content in the origin file with a wiki-link to the new file
                            const edit = new vscode.WorkspaceEdit();
                            const wikiLink = NoteWorkspace.wikiLinkCompletionForConvention(destinationUri, originEditor.document);
                            edit.replace(originEditor.document.uri, originSelectionRange, NoteWorkspace.selectionReplacementContent(wikiLink, noteName));
                            vscode.workspace.applyEdit(edit);
                        }
                    }
                });
            }, (err) => {
                vscode.window.showErrorMessage('Error creating new note.');
            });
        }
        static createNewNoteFile(noteTitle) {
            var _a;
            let workspacePath = '';
            if (vscode.workspace.workspaceFolders) {
                workspacePath = vscode.workspace.workspaceFolders[0].uri.fsPath.toString();
            }
            const activeFile = (_a = vscode.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document;
            let activePath = activeFile ? path_1.dirname(activeFile.uri.fsPath) : null;
            let noteDirectory = this.newNoteDirectory();
            // first handle the case where we try to use same dir as active note:
            if (noteDirectory == this.NEW_NOTE_SAME_AS_ACTIVE_NOTE) {
                if (activePath) {
                    noteDirectory = activePath;
                }
                else {
                    vscode.window.showWarningMessage(`Error. newNoteDirectory was NEW_NOT_SAME_AS_ACTIVE_NOTE but no active note directory found. Using WORKSPACE_ROOT.`);
                    noteDirectory = this.NEW_NOTE_WORKSPACE_ROOT;
                }
            }
            // next, handle a case where this is set to a custom path
            if (noteDirectory != this.NEW_NOTE_WORKSPACE_ROOT) {
                // If the noteDirectory was set from the current activePath,
                // it will already be absolute.
                // Also, might as well handle case where user has
                // an absolute path in their settings.
                if (!path_1.isAbsolute(noteDirectory)) {
                    noteDirectory = path_1.join(workspacePath, noteDirectory);
                }
                const dirExists = fs_1.existsSync(noteDirectory);
                if (!dirExists) {
                    vscode.window.showWarningMessage(`Error. newNoteDirectory \`${noteDirectory}\` does not exist. Using WORKSPACE_ROOT.`);
                    noteDirectory = this.NEW_NOTE_WORKSPACE_ROOT;
                }
            }
            // need to recheck this in case we handled correctly above.
            // on errors, we will have set to this value:
            if (noteDirectory == this.NEW_NOTE_WORKSPACE_ROOT) {
                noteDirectory = workspacePath;
            }
            const filename = NoteWorkspace.noteFileNameFromTitle(noteTitle);
            const filepath = path_1.join(noteDirectory, filename);
            const fileAlreadyExists = fs_1.existsSync(filepath);
            if (fileAlreadyExists) {
                vscode.window.showWarningMessage(`Error creating note, file at path already exists: ${filepath}`);
            }
            else {
                // create the file if it does not exist
                const contents = NoteWorkspace.newNoteContent(noteTitle);
                fs_1.writeFileSync(filepath, contents);
            }
            return {
                filepath: filepath,
                fileAlreadyExists: fileAlreadyExists,
            };
        }
        static newNoteContent(noteName) {
            const template = NoteWorkspace.newNoteTemplate();
            const d = (new Date().toISOString().match(/(\d{4}-\d{2}-\d{2})/) || '')[0]; // "2020-08-25"
            const t = new Date().toISOString(); // "2020-08-25T03:21:49.735Z"
            const contents = template
                .replace(/\\n/g, '\n')
                .replace(/\$\{noteName\}/g, noteName)
                .replace(/\$\{timestamp\}/g, t)
                .replace(/\$\{date\}/g, d);
            return contents;
        }
        static selectionReplacementContent(wikiLink, noteName) {
            const template = NoteWorkspace.newNoteFromSelectionReplacementTemplate();
            const contents = template
                .replace(/\$\{wikiLink\}/g, wikiLink)
                .replace(/\$\{noteName\}/g, noteName);
            return contents;
        }
        static overrideMarkdownWordPattern() {
            // console.debug('overrideMarkdownWordPattern');
            this.DOCUMENT_SELECTOR.map((ds) => {
                vscode.languages.setLanguageConfiguration(ds.language, {
                    wordPattern: this.rxMarkdownWordPattern(),
                });
            });
        }
        static noteFiles() {
            return __awaiter(this, void 0, void 0, function* () {
                let that = this;
                // let files = await vscode.workspace.findFiles('**/*');
                let files = yield findNonIgnoredFiles_1.default('**/*');
                files = files.filter((f) => f.scheme == 'file' && f.path.match(that.rxFileExtensions()));
                this.noteFileCache = files;
                return files;
            });
        }
        static noteFilesFromCache() {
            return this.noteFileCache;
        }
    }
    // Defining these as strings now, and then compiling them with accessor methods.
    // This will allow us to potentially expose these as settings.
    // Note for the future: \p{L} is used instead of \w , in order to match to all possible letters
    // rather than just those from the latin alphabet.
    NoteWorkspace._rxTag = '(?<= |,|^)#[\\p{L}\\-_]+'; // match # followed by a letter character
    NoteWorkspace._rxBeginTag = '(?<= |,|^)#'; // match # preceded by a space, comma, or newline, regardless of whether it is followed by a letter character
    NoteWorkspace._rxWikiLink = '\\[\\[[^sep\\]]+(sep[^sep\\]]+)?\\]\\]'; // [[wiki-link-regex(|with potential pipe)?]] Note: "sep" will be replaced with pipedWikiLinksSeparator on compile
    NoteWorkspace._rxTitle = '(?<=^( {0,3}#[^\\S\\r\\n]+)).+';
    NoteWorkspace._rxMarkdownWordPattern = '([_\\p{L}\\d#\\.\\/\\\\]+)'; // had to add [".", "/", "\"] to get relative path completion working and ["#"] to get tag completion working
    NoteWorkspace._rxMarkdownHyperlink = '\\[[^\\[\\]]*\\]\\((?!https?)[^\\(\\)\\[\\] ]+\\)'; // [description](hyperlink-to-file.md), ensuring the link doesn't start with http(s)
    NoteWorkspace._rxFileExtensions = '\\.(md|markdown|mdx|fountain|txt)$';
    NoteWorkspace.SLUGIFY_NONE = 'NONE';
    NoteWorkspace.NEW_NOTE_SAME_AS_ACTIVE_NOTE = 'SAME_AS_ACTIVE_NOTE';
    NoteWorkspace.NEW_NOTE_WORKSPACE_ROOT = 'WORKSPACE_ROOT';
    NoteWorkspace.DEFAULT_CONFIG = {
        createNoteOnGoToDefinitionWhenMissing: true,
        compileSuggestionDetails: false,
        defaultFileExtension: 'md',
        noteCompletionConvention: NoteCompletionConvention.rawFilename,
        slugifyCharacter: SlugifyCharacter.dash,
        slugifyMethod: SlugifyMethod.classic,
        workspaceFilenameConvention: WorkspaceFilenameConvention.uniqueFilenames,
        newNoteTemplate: '# ${noteName}\n\n',
        newNoteFromSelectionReplacementTemplate: '[[${wikiLink}]]',
        lowercaseNewNoteFilenames: true,
        triggerSuggestOnReplacement: true,
        allowPipedWikiLinks: false,
        pipedWikiLinksSyntax: PipedWikiLinksSyntax.fileDesc,
        pipedWikiLinksSeparator: '\\|',
        newNoteDirectory: NoteWorkspace.NEW_NOTE_SAME_AS_ACTIVE_NOTE,
        previewLabelStyling: PreviewLabelStyling.brackets,
        previewShowFileExtension: false,
    };
    NoteWorkspace.DOCUMENT_SELECTOR = [
        // { scheme: 'file', language: 'markdown' },
        // { scheme: 'file', language: 'mdx' },
        { language: 'markdown' },
        { language: 'mdx' },
    ];
    // Cache object to store results from noteFiles() in order to provide a synchronous method to the preview renderer.
    NoteWorkspace.noteFileCache = [];
    return NoteWorkspace;
})();
exports.NoteWorkspace = NoteWorkspace;
//# sourceMappingURL=NoteWorkspace.js.map