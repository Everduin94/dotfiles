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
exports.MarkdownFileCompletionItemProvider = void 0;
const vscode = require("vscode");
const Ref_1 = require("./Ref");
const NoteWorkspace_1 = require("./NoteWorkspace");
const NoteParser_1 = require("./NoteParser");
const BibTeXCitations_1 = require("./BibTeXCitations");
class MarkdownFileCompletionItem extends vscode.CompletionItem {
    constructor(label, kind, fsPath) {
        super(label, kind);
        this.fsPath = fsPath;
    }
}
// Given a document and position, check whether the current word matches one of
// these 3 contexts:
// 1. [[wiki-links]]
// 2. #tags
// 3. @bibtext-reference
//
// If so, provide appropriate completion items from the current workspace
class MarkdownFileCompletionItemProvider {
    provideCompletionItems(document, position, _token, context) {
        return __awaiter(this, void 0, void 0, function* () {
            const ref = Ref_1.getRefOrEmptyRefAt(document, position);
            switch (ref.type) {
                case Ref_1.RefType.Null:
                    return [];
                case Ref_1.RefType.Tag:
                    return (yield NoteParser_1.NoteParser.distinctTags()).map((t) => {
                        let kind = vscode.CompletionItemKind.File;
                        let label = `${t}`; // cast to a string
                        let item = new vscode.CompletionItem(label, kind);
                        if (ref && ref.range) {
                            item.range = ref.range;
                        }
                        return item;
                    });
                case Ref_1.RefType.WikiLink:
                    return (yield NoteWorkspace_1.NoteWorkspace.noteFiles()).map((f) => {
                        let kind = vscode.CompletionItemKind.File;
                        let label = NoteWorkspace_1.NoteWorkspace.wikiLinkCompletionForConvention(f, document);
                        let item = new MarkdownFileCompletionItem(label, kind, f.fsPath);
                        if (ref && ref.range) {
                            item.range = ref.range;
                        }
                        return item;
                    });
                case Ref_1.RefType.BibTeX:
                    return (yield BibTeXCitations_1.BibTeXCitations.citations()).map((r) => {
                        let kind = vscode.CompletionItemKind.File;
                        let label = `${r}`; // cast to a string
                        let item = new vscode.CompletionItem(label, kind);
                        return item;
                    });
                default:
                    return [];
            }
        });
    }
    resolveCompletionItem(item, token) {
        var _a;
        return __awaiter(this, void 0, void 0, function* () {
            const fsPath = item.fsPath;
            if (fsPath) {
                let note = NoteParser_1.NoteParser.noteFromFsPath(fsPath);
                if (note) {
                    item.detail = (_a = note.title) === null || _a === void 0 ? void 0 : _a.text;
                    item.documentation = note.documentation();
                }
            }
            return item;
        });
    }
}
exports.MarkdownFileCompletionItemProvider = MarkdownFileCompletionItemProvider;
//# sourceMappingURL=MarkdownFileCompletionItemProvider.js.map