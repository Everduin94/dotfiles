"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const os_1 = __importDefault(require("os"));
const vscode_1 = require("vscode");
const foam_core_1 = require("foam-core");
const vsc_utils_1 = require("./vsc-utils");
describe('uri conversion', () => {
    it('uses drive letter casing in windows #488 #507', () => {
        if (os_1.default.platform() === 'win32') {
            const uri = vscode_1.workspace.workspaceFolders[0].uri;
            const isDriveUppercase = uri.fsPath.charCodeAt(0) >= 'A'.charCodeAt(0) &&
                uri.fsPath.charCodeAt(0) <= 'Z'.charCodeAt(0);
            const [drive, path] = uri.fsPath.split(':');
            const posixPath = path.replace(/\\/g, '/');
            const withUppercase = `/${drive.toUpperCase()}:${posixPath}`;
            const withLowercase = `/${drive.toLowerCase()}:${posixPath}`;
            const expected = isDriveUppercase ? withUppercase : withLowercase;
            expect(vsc_utils_1.fromVsCodeUri(vscode_1.Uri.file(withUppercase)).path).toEqual(expected);
            expect(vsc_utils_1.fromVsCodeUri(vscode_1.Uri.file(withLowercase)).path).toEqual(expected);
        }
    });
    it('correctly parses file paths', () => {
        const test = vscode_1.workspace.workspaceFolders[0].uri;
        const uri = foam_core_1.URI.file(test.fsPath);
        expect(uri).toEqual(foam_core_1.URI.create({
            scheme: 'file',
            path: test.path,
        }));
    });
    it('creates a proper string representation for file uris', () => {
        const test = vscode_1.workspace.workspaceFolders[0].uri;
        const uri = foam_core_1.URI.file(test.fsPath);
        expect(foam_core_1.URI.toString(uri)).toEqual(test.toString());
    });
    it('is consistent when converting from VS Code to Foam URI', () => {
        const vsUri = vscode_1.workspace.workspaceFolders[0].uri;
        const fUri = vsc_utils_1.fromVsCodeUri(vsUri);
        expect(vsc_utils_1.toVsCodeUri(fUri)).toEqual(expect.objectContaining(fUri));
    });
    it('is consistent when converting from Foam to VS Code URI', () => {
        const test = vscode_1.workspace.workspaceFolders[0].uri;
        const uri = foam_core_1.URI.file(test.fsPath);
        const fUri = vsc_utils_1.toVsCodeUri(uri);
        expect(fUri).toEqual(expect.objectContaining({
            scheme: 'file',
            path: test.path,
        }));
        expect(vsc_utils_1.fromVsCodeUri(fUri)).toEqual(uri);
    });
});
//# sourceMappingURL=vsc-utils.test.js.map