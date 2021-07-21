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
exports.MarkdownDefinitionProvider = void 0;
const vscode = require("vscode");
const Ref_1 = require("./Ref");
const NoteWorkspace_1 = require("./NoteWorkspace");
const path_1 = require("path");
const fs_1 = require("fs");
const BibTeXCitations_1 = require("./BibTeXCitations");
// Given a document and position, check whether the current word matches one of
// this context: [[wiki-link]]
//
// If so, we look for a file in the current workspace named by the wiki link
// If the file `wiki-link.md` exists, return the first line of that file as the
// Definition for the word.
//
// Optionally, when no existing note is found for the wiki-link
// vscodeMarkdownNotes.createNoteOnGoToDefinitionWhenMissing = true
// AND vscodeMarkdownNotes.workspaceFilenameConvention = 'uniqueFilenames'
// THEN create the missing file at the workspace root.
let MarkdownDefinitionProvider = /** @class */ (() => {
    class MarkdownDefinitionProvider {
        provideDefinition(document, position, token) {
            return __awaiter(this, void 0, void 0, function* () {
                const ref = Ref_1.getRefAt(document, position);
                if (ref.type == Ref_1.RefType.BibTeX) {
                    return yield BibTeXCitations_1.BibTeXCitations.location(ref.word);
                }
                if (ref.type != Ref_1.RefType.WikiLink && ref.type != Ref_1.RefType.Hyperlink) {
                    return [];
                }
                let files = [];
                files = yield MarkdownDefinitionProvider.filesForWikiLinkRef(ref, document);
                // else, create the file
                if (files.length == 0) {
                    const path = MarkdownDefinitionProvider.createMissingNote(ref);
                    if (path !== undefined) {
                        files.push(vscode.Uri.file(path));
                    }
                }
                const p = new vscode.Position(0, 0);
                return files.map((f) => new vscode.Location(f, p));
            });
        }
        static filesForWikiLinkRef(ref, relativeToDocument) {
            return __awaiter(this, void 0, void 0, function* () {
                let files = yield NoteWorkspace_1.NoteWorkspace.noteFiles();
                return this._filesForWikiLinkRefAndNoteFiles(ref, relativeToDocument, files);
            });
        }
        static filesForWikiLinkRefFromCache(ref, relativeToDocument) {
            let files = NoteWorkspace_1.NoteWorkspace.noteFilesFromCache(); // TODO: cache results from NoteWorkspace.noteFiles()
            return this._filesForWikiLinkRefAndNoteFiles(ref, relativeToDocument, files);
        }
        // Brunt of the logic for either
        // filesForWikiLinkRef
        // or, filesForWikiLinkRefFromCache
        static _filesForWikiLinkRefAndNoteFiles(ref, relativeToDocument, noteFiles) {
            let files = [];
            // ref.word might be either:
            // a basename for a unique file in the workspace
            // or, a relative path to a file
            // Since, ref.word is just a string of text from a document,
            // there is no guarantee useUniqueFilenames will tell us
            // it is not a relative path.
            // However, only check for basenames in the entire project if:
            if (NoteWorkspace_1.NoteWorkspace.useUniqueFilenames()) {
                // there should be exactly 1 file with name = ref.word
                files = noteFiles.filter((f) => {
                    return NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch(f.fsPath, ref.word);
                });
            }
            // If we did not find any files in the workspace,
            // see if a file exists at the relative path:
            if (files.length == 0 && relativeToDocument && relativeToDocument.uri) {
                const relativePath = ref.word;
                let fromDir = path_1.dirname(relativeToDocument.uri.fsPath.toString());
                const absPath = path_1.resolve(fromDir, relativePath);
                if (fs_1.existsSync(absPath)) {
                    const f = vscode.Uri.file(absPath);
                    files.push(f);
                }
            }
            return files;
        }
    }
    MarkdownDefinitionProvider.createMissingNote = (ref) => {
        var _a;
        // don't create new files if ref is a Tag
        if (ref.type != Ref_1.RefType.WikiLink) {
            return;
        }
        if (!NoteWorkspace_1.NoteWorkspace.createNoteOnGoToDefinitionWhenMissing()) {
            return;
        }
        const filename = (_a = vscode.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document.fileName;
        if (filename !== undefined) {
            if (!NoteWorkspace_1.NoteWorkspace.useUniqueFilenames()) {
                vscode.window.showWarningMessage(`createNoteOnGoToDefinitionWhenMissing only works when vscodeMarkdownNotes.workspaceFilenameConvention = 'uniqueFilenames'`);
                return;
            }
            const title = NoteWorkspace_1.NoteWorkspace.stripExtension(ref.word);
            const { filepath, fileAlreadyExists } = NoteWorkspace_1.NoteWorkspace.createNewNoteFile(title);
            return filepath;
        }
    };
    return MarkdownDefinitionProvider;
})();
exports.MarkdownDefinitionProvider = MarkdownDefinitionProvider;
//# sourceMappingURL=MarkdownDefinitionProvider.js.map