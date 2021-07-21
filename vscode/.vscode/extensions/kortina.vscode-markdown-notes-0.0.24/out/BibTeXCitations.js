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
exports.BibTeXCitations = void 0;
const vscode = require("vscode");
const fs_1 = require("fs");
const path_1 = require("path");
let BibTeXCitations = /** @class */ (() => {
    class BibTeXCitations {
        static cfg() {
            let c = vscode.workspace.getConfiguration('vscodeMarkdownNotes');
            return {
                bibTeXFilePath: c.get('bibtexFilePath'),
            };
        }
        static isBibtexFileConfigured() {
            return fs_1.existsSync(this.bibTexFilePath());
        }
        static rxBibTeX() {
            return this._rxBibTeXInNote;
        }
        static citations() {
            return __awaiter(this, void 0, void 0, function* () {
                return this.bibTeXFile().then((x) => this.parseCitations(x));
            });
        }
        static location(citation) {
            return __awaiter(this, void 0, void 0, function* () {
                return this.bibTeXFile().then((x) => {
                    const pos = this.position(x, citation);
                    if (pos == null) {
                        return Promise.reject('Cannot get location');
                    }
                    else {
                        const uri = vscode.Uri.file(this.bibTexFilePath());
                        return new vscode.Location(uri, pos);
                    }
                });
            });
        }
        static bibTexFilePath() {
            var _a;
            const path = this.cfg().bibTeXFilePath;
            // Absolute path (Unix and Windows)
            if (path.startsWith('/') || path.indexOf(':\\') == 1) {
                return path;
            }
            // Workspace relative path
            const folders = (_a = vscode.workspace) === null || _a === void 0 ? void 0 : _a.workspaceFolders;
            if (folders && folders.length > 0) {
                return path_1.join(folders[0].uri.fsPath.toString(), path);
            }
            return path;
        }
        static bibTeXFile() {
            const path = this.bibTexFilePath();
            if (path == null || path == '') {
                return Promise.reject('BibTeX file location not set');
            }
            return new Promise((resolve, reject) => {
                fs_1.readFile(path, (error, buffer) => {
                    if (error) {
                        reject(error);
                    }
                    else {
                        resolve(buffer.toString());
                    }
                });
            });
        }
        static parseCitations(data) {
            let matches = data.matchAll(this._rxBibTeXInLibrary);
            return Array.from(matches).map((x) => x[1]);
        }
        static position(data, citation) {
            var _a;
            let pos = (_a = data.match(citation)) === null || _a === void 0 ? void 0 : _a.index;
            if (pos == null) {
                return null;
            }
            const numLines = data.substring(0, pos).split('\n').length;
            return new vscode.Position(numLines - 1, 0);
        }
    }
    BibTeXCitations._rxBibTeXInNote = /(?<= |,|^|\[|\[-)@[\p{L}\d\-_]+(?!\(.\S\))/giu;
    BibTeXCitations._rxBibTeXInLibrary = /^@\S+{(\S+),/gm;
    return BibTeXCitations;
})();
exports.BibTeXCitations = BibTeXCitations;
//# sourceMappingURL=BibTeXCitations.js.map