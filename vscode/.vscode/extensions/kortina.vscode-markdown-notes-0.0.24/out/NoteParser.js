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
exports.NoteParser = exports.Note = void 0;
const vscode = require("vscode");
const path_1 = require("path");
const fs_1 = require("fs");
const fsp = require('fs').promises;
const Ref_1 = require("./Ref");
const NoteWorkspace_1 = require("./NoteWorkspace");
const RETURN_TYPE_VSCODE = 'vscode';
let RefCandidate = /** @class */ (() => {
    class RefCandidate {
        constructor(rawText, range, refType) {
            this.rawText = rawText;
            this.range = range;
            this.refType = refType;
        }
        matchesContextWord(ref) {
            if (ref.type != this.refType) {
                return false;
            }
            if (ref.type == Ref_1.RefType.Tag) {
                return this.rawText == `#${ref.word}`;
            }
            else if (ref.type == Ref_1.RefType.WikiLink) {
                return NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatchText(this.rawText, ref.word);
            }
            else if (ref.type == Ref_1.RefType.Hyperlink) {
                return NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatchHyperlinks(this.rawText, ref.word);
            }
            return false;
        }
    }
    RefCandidate.fromMatch = (lineNum, match, cwType) => {
        // console.debug(`RefCandidate.fromMatch`, match[0]);
        let s = match.index || 0;
        let e = s + match[0].length;
        let r = {
            start: { line: lineNum, character: s },
            end: { line: lineNum, character: e },
        };
        return new RefCandidate(match[0], r, cwType);
    };
    return RefCandidate;
})();
// Caches the results of reading and parsing a TextDocument
// into an in-memory index,
// so we don't have to re-parse the file
// every time we want to get the locations of
// the Tags and WikiLinks in it
class Note {
    constructor(fsPath) {
        this.refCandidates = [];
        this._parsed = false;
        this.fsPath = fsPath;
    }
    // mostly used as a constructor for tests
    // when we don't want to actually parse something
    // from the filesystem.
    // Won't fail because the init does not do anything with fsPath
    static fromData(data) {
        let note = new Note('NO_PATH');
        note.data = data;
        note.parseData(false);
        return note;
    }
    // read fsPath into this.data and return a
    // Promise that resolves to `this` Note instance.
    // Usage:
    // note.readFile().then(note => console.log(note.data));
    readFile(useCache = false) {
        // console.debug(`readFile: ${this.fsPath}`);
        let that = this;
        // if we are using the cache and cached data exists,
        // just resolve immediately without re-reading files
        if (useCache && this.data) {
            return new Promise((resolve) => {
                resolve(that);
            });
        }
        // make sure we reset parsed to false because we are re-reading the file
        // and we don't want to end up using the old parsed refCandidates
        // in the event that parseData(true) is called in the interim
        this._parsed = false;
        return new Promise((resolve, reject) => {
            fs_1.readFile(that.fsPath, (err, buffer) => {
                if (err) {
                    reject(err);
                }
                else {
                    // NB! Make sure to cast this to a string
                    // otherwise, it will cause weird silent failures
                    that.data = `${buffer}`;
                    resolve(that);
                }
            });
        });
    }
    parseData(useCache = false) {
        let that = this;
        // don't debug on blank data, only null|undefined
        if (this.data === '') {
            return;
        }
        if (!this.data) {
            console.debug(`RefCandidate.parseData: no data for ${this.fsPath}`);
            return;
        }
        if (useCache && this._parsed) {
            return;
        }
        // reset the refCandidates Array
        this.refCandidates = [];
        let searchTitle = true;
        let isSkip = false;
        let lines = this.data.split(/\r?\n/);
        lines.map((line, lineNum) => {
            if (isSkip) {
                // ! skip all empty lines after title `# title`
                if (line.trim() == '') {
                    that.title.contextLine = lineNum;
                }
                else {
                    isSkip = false;
                }
            }
            if (searchTitle) {
                Array.from(line.matchAll(NoteWorkspace_1.NoteWorkspace.rxTitle())).map((match) => {
                    that.title = {
                        text: '# ' + match[0].trim(),
                        line: lineNum,
                        contextLine: lineNum,
                    };
                    searchTitle = false; // * only search for the first # h1
                    isSkip = true;
                });
            }
            Array.from(line.matchAll(NoteWorkspace_1.NoteWorkspace.rxTag())).map((match) => {
                that.refCandidates.push(RefCandidate.fromMatch(lineNum, match, Ref_1.RefType.Tag));
            });
            Array.from(line.matchAll(NoteWorkspace_1.NoteWorkspace.rxWikiLink()) || []).map((match) => {
                // console.log('match tag', that.fsPath, lineNum, match);
                that.refCandidates.push(RefCandidate.fromMatch(lineNum, match, Ref_1.RefType.WikiLink));
            });
            Array.from(line.matchAll(NoteWorkspace_1.NoteWorkspace.rxMarkdownHyperlink())).map((match) => {
                that.refCandidates.push(RefCandidate.fromMatch(lineNum, match, Ref_1.RefType.Hyperlink));
            });
        });
        // console.debug(`parsed ${this.fsPath}. refCandidates:`, this.refCandidates);
        this._parsed = true;
    }
    // NB: assumes this.parseData MUST have been called BEFORE running
    _rawRangesForWord(ref) {
        let ranges = [];
        // don't debug on blank data, only null|undefined
        if (this.data === '') {
            return [];
        }
        if (!this.data || !this.refCandidates) {
            console.debug('rangesForWordInDocumentData called with when !this.data || !this.refCandidates');
            return [];
        }
        if (!ref) {
            return [];
        }
        if (![Ref_1.RefType.Tag, Ref_1.RefType.WikiLink, Ref_1.RefType.Hyperlink].includes(ref.type)) {
            return [];
        }
        return this.refCandidates.filter((c) => c.matchesContextWord(ref)).map((c) => c.range);
    }
    vscodeRangesForWord(ref) {
        return this._rawRangesForWord(ref).map((r) => {
            return new vscode.Range(new vscode.Position(r.start.line, r.start.character), new vscode.Position(r.end.line, r.end.character));
        });
    }
    tagSet() {
        let _tagSet = new Set();
        this.refCandidates
            .filter((rc) => rc.refType == Ref_1.RefType.Tag)
            .map((rc) => {
            _tagSet.add(rc.rawText);
        });
        return _tagSet;
    }
    // completionItem.documentation ()
    documentation() {
        if (this.data === undefined) {
            return '';
        }
        else {
            let data = this.data;
            if (this.title) {
                // get the portion of the note after the title
                data = this.data
                    .split(/\r?\n/)
                    .slice(this.title.contextLine + 1)
                    .join('\n');
            }
            if (NoteWorkspace_1.NoteWorkspace.compileSuggestionDetails()) {
                try {
                    let result = new vscode.MarkdownString(data);
                    return result;
                }
                catch (error) {
                    return '';
                }
            }
            else {
                return data;
            }
        }
    }
}
exports.Note = Note;
let NoteParser = /** @class */ (() => {
    class NoteParser {
        static distinctTags() {
            return __awaiter(this, void 0, void 0, function* () {
                let useCache = true;
                let _tags = [];
                yield NoteParser.parsedFilesForWorkspace(useCache).then((pfs) => {
                    pfs.map((note) => {
                        _tags = _tags.concat(Array.from(note.tagSet()));
                    });
                });
                return Array.from(new Set(_tags));
            });
        }
        static searchBacklinksFor(fileBasename, refType) {
            return __awaiter(this, void 0, void 0, function* () {
                let ref = {
                    type: refType,
                    hasExtension: true,
                    word: fileBasename,
                    range: undefined,
                };
                return this.search(ref);
            });
        }
        static parsedFileFor(fsPath) {
            let note = NoteParser._notes[fsPath];
            if (!note) {
                note = new Note(fsPath);
            }
            this._notes[fsPath] = note;
            return note;
        }
        static parsedFilesForWorkspace(useCache = false) {
            return __awaiter(this, void 0, void 0, function* () {
                let files = yield NoteWorkspace_1.NoteWorkspace.noteFiles();
                let parsedFiles = files.map((f) => NoteParser.parsedFileFor(f.fsPath));
                return (yield Promise.all(parsedFiles.map((note) => note.readFile(useCache)))).map((note) => {
                    note.parseData(useCache);
                    return note;
                });
            });
        }
        // call this when we know a file has changed contents to update the cache
        static updateCacheFor(fsPath) {
            let that = this;
            let note = NoteParser.parsedFileFor(fsPath);
            note.readFile(false).then((_pf) => {
                _pf.parseData(false);
                // remember to set in the master index:
                that._notes[fsPath] = _pf;
            });
        }
        // call this when we know a file has been deleted
        static clearCacheFor(fsPath) {
            delete NoteParser._notes[fsPath];
        }
        static hydrateCache() {
            return __awaiter(this, void 0, void 0, function* () {
                let useCache = false;
                let parsedFiles = yield NoteParser.parsedFilesForWorkspace(useCache);
                return parsedFiles;
            });
        }
        static search(ref) {
            return __awaiter(this, void 0, void 0, function* () {
                let useCache = true;
                let locations = [];
                let query;
                if (ref.type == Ref_1.RefType.Tag) {
                    query = `#${ref.word}`;
                }
                else if (ref.type == Ref_1.RefType.WikiLink) {
                    query = `[[${path_1.basename(ref.word)}]]`;
                }
                else if (ref.type == Ref_1.RefType.Hyperlink) {
                    query = `](${path_1.basename(ref.word)})`;
                }
                else {
                    return [];
                }
                let parsedFiles = yield NoteParser.parsedFilesForWorkspace(useCache);
                parsedFiles.map((note, i) => {
                    let ranges = note.vscodeRangesForWord(ref);
                    ranges.map((r) => {
                        let loc = new vscode.Location(vscode.Uri.file(note.fsPath), r);
                        locations.push(loc);
                    });
                });
                return locations;
            });
        }
        static noteFromFsPath(fsPath) {
            return this._notes[fsPath];
        }
    }
    // mapping of file fsPaths to Note objects
    NoteParser._notes = {};
    return NoteParser;
})();
exports.NoteParser = NoteParser;
//# sourceMappingURL=NoteParser.js.map