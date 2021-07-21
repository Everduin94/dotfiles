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
exports.API = void 0;
const MarkdownDefinitionProvider_1 = require("./MarkdownDefinitionProvider");
const NoteParser_1 = require("./NoteParser");
const NoteWorkspace_1 = require("./NoteWorkspace");
const Ref_1 = require("./Ref");
// This class serves as the public interface to commands that this extension exposes.
class API {
    // Use vscode.window.showInputBox
    // to prompt user for a new note name
    // and create it upon entry.
    static newNote(context) {
        return NoteWorkspace_1.NoteWorkspace.newNote(context);
    }
    // Given some wiki-link text (from between double-brackets) such as "my-note" or "my-note.md"
    // return a Note[] (typically of length 1)
    // where the note filename is a match for the wiki-link text.
    // and
    // type Note = {
    //   fsPath: string; // filesystem path to the Note
    //   data: string; // text contents of the Note
    // };
    //
    // example:
    // let notes = await vscode.commands.executeCommand('vscodeMarkdownNotes.notesForWikiLink', 'demo');
    static notesForWikiLink(wikiLinkText, relativeToDocument) {
        return __awaiter(this, void 0, void 0, function* () {
            const ref = Ref_1.refFromWikiLinkText(wikiLinkText);
            let files = yield MarkdownDefinitionProvider_1.MarkdownDefinitionProvider.filesForWikiLinkRef(ref, relativeToDocument); // TODO: async
            let notes = (files || [])
                .filter((f) => f.fsPath)
                .map((f) => NoteParser_1.NoteParser.noteFromFsPath(f.fsPath))
                // see: https://stackoverflow.com/questions/43010737/way-to-tell-typescript-compiler-array-prototype-filter-removes-certain-types-fro
                .filter((n) => {
                return n != undefined;
            });
            return Promise.resolve(notes);
        });
    }
}
exports.API = API;
//# sourceMappingURL=API.js.map