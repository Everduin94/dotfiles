"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BacklinksTreeDataProvider = void 0;
const vscode = require("vscode");
const fs = require("fs");
const path = require("path");
const NoteParser_1 = require("./NoteParser");
const Ref_1 = require("./Ref");
class BacklinksTreeDataProvider {
    constructor(workspaceRoot) {
        this.workspaceRoot = workspaceRoot;
        this._onDidChangeTreeData = new vscode.EventEmitter();
        this.onDidChangeTreeData = this._onDidChangeTreeData.event;
    }
    reload() {
        this._onDidChangeTreeData.fire();
    }
    getTreeItem(element) {
        return element;
    }
    // Take a flat list of locations, such as:
    // - file1.md, l1
    // - file2.md, l2
    // - file1.md, l3
    // And return as list of files with location lists:
    // - file1.md
    //   - l1
    //   - l3
    // - file2.md
    //   - l2
    // NB: does work well with relativePaths mode, assumes uniqueFilenames
    static locationListToTree(locations) {
        let m = {};
        locations.map((l) => {
            let f = path.basename(l.uri.fsPath);
            if (!m[f]) {
                let fwl = {
                    file: f,
                    locations: [],
                };
                m[f] = fwl;
            }
            m[f].locations.push(l);
        });
        let arr = Object.values(m);
        // sort the files by name:
        let asc = (a, b) => {
            if (a < b) {
                return -1;
            }
            if (a > b) {
                return 1;
            }
            return 0;
        };
        arr.sort((a, b) => asc(a.file, b.file));
        // sort the locations in each file by start position:
        return arr.map((fwl) => {
            fwl.locations.sort((locA, locB) => {
                let a = locA.range.start;
                let b = locB.range.start;
                if (a.line < b.line) {
                    return -1;
                }
                if (a.line > b.line) {
                    return 1;
                }
                // same line, compare chars
                if (a.character < b.character) {
                    return -1;
                }
                if (a.character > b.character) {
                    return 1;
                }
                return 0;
            });
            return fwl;
        });
    }
    getChildren(element) {
        var _a;
        let f = (_a = vscode.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document.uri.fsPath;
        if (!f) {
            // no activeTextEditor, so there can be no refs
            return Promise.resolve([]);
        }
        if (!this.workspaceRoot) {
            vscode.window.showInformationMessage('No refs in empty workspace');
            return Promise.resolve([]);
        }
        let activeFilename = path.basename(f);
        // TOP LEVEL:
        // Parse the workspace into list of FilesWithLocations
        // Return 1 collapsible element per file
        if (!element) {
            return Promise.all([
                NoteParser_1.NoteParser.searchBacklinksFor(activeFilename, Ref_1.RefType.WikiLink),
                NoteParser_1.NoteParser.searchBacklinksFor(activeFilename, Ref_1.RefType.Hyperlink),
            ]).then((arr) => {
                let locations = arr[0].concat(arr[1]);
                let filesWithLocations = BacklinksTreeDataProvider.locationListToTree(locations);
                return filesWithLocations.map((fwl) => BacklinkItem.fromFileWithLocations(fwl));
            });
            // Given the collapsible elements,
            // return the children, 1 for each location within the file
        }
        else if (element && element.locations) {
            return Promise.resolve(element.locations.map((l) => BacklinkItem.fromLocation(l, element.filename)));
        }
        else {
            return Promise.resolve([]);
        }
    }
}
exports.BacklinksTreeDataProvider = BacklinksTreeDataProvider;
class BacklinkItem extends vscode.TreeItem {
    constructor(label, collapsibleState, locations, location, filename) {
        super(label, collapsibleState);
        this.label = label;
        this.collapsibleState = collapsibleState;
        this.locations = locations;
        this.location = location;
        this.filename = filename;
        this.filename = filename || '';
    }
    // return the 1 collapsible Item for each file
    // store the locations within that file to the .locations attribute
    static fromFileWithLocations(fwl) {
        let label = fwl.file;
        let cs = vscode.TreeItemCollapsibleState.Expanded;
        return new BacklinkItem(label, cs, fwl.locations, undefined, fwl.file);
    }
    // items for the locations within files
    static fromLocation(location, filename) {
        // location / range is 0-indexed, but editor lines are 1-indexed
        let lineNum = location.range.start.line + 1;
        let label = `${lineNum}:`; // path.basename(location.uri.fsPath);
        let cs = vscode.TreeItemCollapsibleState.None;
        return new BacklinkItem(label, cs, undefined, location, filename);
    }
    get command() {
        if (this.location) {
            return {
                command: 'vscode.open',
                arguments: [
                    this.location.uri,
                    {
                        preview: true,
                        selection: this.location.range,
                    },
                ],
                title: 'Open File',
            };
        }
    }
    get tooltip() {
        return [this.filename, this.lineText, this.description].filter(Boolean).join(': ');
    }
    get lineText() {
        var _a;
        if (this.location) {
            return `line ${(_a = this.location) === null || _a === void 0 ? void 0 : _a.range.start.line}`;
        }
    }
    get description() {
        var _a, _b, _c, _d, _e;
        let d = ``;
        if (this.location) {
            let lines = (fs.readFileSync((_a = this.location) === null || _a === void 0 ? void 0 : _a.uri.fsPath) || '').toString().split(/\r?\n/);
            let line = lines[(_b = this.location) === null || _b === void 0 ? void 0 : _b.range.start.line];
            // Look back 12 chars before the start of the reference.
            // There is almost certainly a more elegant way to do this.
            let s = ((_c = this.location) === null || _c === void 0 ? void 0 : _c.range.start.character) - 12;
            if (s < 20) {
                s = 0;
            }
            return line.substr(s);
        }
        else if (this.locations) {
            let r = ((_d = this.locations) === null || _d === void 0 ? void 0 : _d.length) == 1 ? 'Reference' : 'References';
            d = `${(_e = this.locations) === null || _e === void 0 ? void 0 : _e.length} ${r}`;
        }
        return d;
    }
    get iconPath() {
        // to leave more room for the ref text,
        // don't use an icon for each line
        return this.location ? undefined : new vscode.ThemeIcon('references');
    }
}
//# sourceMappingURL=BacklinksTreeDataProvider.js.map