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
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const test_utils_1 = require("../test/test-utils");
const document_link_provider_1 = require("./document-link-provider");
const utility_commands_1 = require("./utility-commands");
const vsc_utils_1 = require("../utils/vsc-utils");
describe('Document links provider', () => {
    const parser = foam_core_1.createMarkdownParser([]);
    beforeAll(async () => {
        await test_utils_1.cleanWorkspace();
    });
    afterAll(async () => {
        await test_utils_1.cleanWorkspace();
    });
    beforeEach(async () => {
        await test_utils_1.closeEditors();
    });
    it('should not return any link for empty documents', async () => {
        const { uri, content } = await test_utils_1.createFile('');
        const ws = new foam_core_1.FoamWorkspace().set(parser.parse(uri, content));
        const doc = await vscode.workspace.openTextDocument(uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(0);
    });
    it('should not return any link for documents without links', async () => {
        const { uri, content } = await test_utils_1.createFile('This is some content without links');
        const ws = new foam_core_1.FoamWorkspace().set(parser.parse(uri, content));
        const doc = await vscode.workspace.openTextDocument(uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(0);
    });
    it('should support wikilinks', async () => {
        const fileB = await test_utils_1.createFile('# File B');
        const fileA = await test_utils_1.createFile(`this is a link to [[${fileB.name}]].`);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const noteB = parser.parse(fileB.uri, fileB.content);
        const ws = test_utils_1.createTestWorkspace()
            .set(noteA)
            .set(noteB);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(1);
        expect(links[0].target).toEqual(utility_commands_1.OPEN_COMMAND.asURI(noteB.uri));
        expect(links[0].range).toEqual(new vscode.Range(0, 18, 0, 27));
    });
    it('should support regular links', async () => {
        const fileB = await test_utils_1.createFile('# File B');
        const fileA = await test_utils_1.createFile(`this is a link to [a file](./${fileB.base}).`);
        const ws = test_utils_1.createTestWorkspace()
            .set(parser.parse(fileA.uri, fileA.content))
            .set(parser.parse(fileB.uri, fileB.content));
        const { doc } = await test_utils_1.showInEditor(fileA.uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(1);
        expect(links[0].target).toEqual(utility_commands_1.OPEN_COMMAND.asURI(fileB.uri));
        expect(links[0].range).toEqual(new vscode.Range(0, 18, 0, 38));
    });
    it('should support placeholders', async () => {
        const fileA = await test_utils_1.createFile(`this is a link to [[a placeholder]].`);
        const ws = new foam_core_1.FoamWorkspace().set(parser.parse(fileA.uri, fileA.content));
        const { doc } = await test_utils_1.showInEditor(fileA.uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(1);
        expect(links[0].target).toEqual(utility_commands_1.OPEN_COMMAND.asURI(vsc_utils_1.toVsCodeUri(foam_core_1.URI.placeholder('a placeholder'))));
        expect(links[0].range).toEqual(new vscode.Range(0, 18, 0, 35));
    });
    it('should support wikilinks that have an alias', async () => {
        const fileB = await test_utils_1.createFile("# File B that's aliased");
        const fileA = await test_utils_1.createFile(`this is a link to [[${fileB.name}|alias]].`);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const noteB = parser.parse(fileB.uri, fileB.content);
        const ws = test_utils_1.createTestWorkspace()
            .set(noteA)
            .set(noteB);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(1);
        expect(links[0].target).toEqual(utility_commands_1.OPEN_COMMAND.asURI(noteB.uri));
        expect(links[0].range).toEqual(new vscode.Range(0, 18, 0, 33));
    });
    it('should support wikilink aliases in tables using escape character', async () => {
        const fileB = await test_utils_1.createFile('# File that has to be aliased');
        const fileA = await test_utils_1.createFile(`
  | Col A | ColB |
  | --- | --- |
  | [[${fileB.name}\\|alias]] | test |
    `);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const noteB = parser.parse(fileB.uri, fileB.content);
        const ws = test_utils_1.createTestWorkspace()
            .set(noteA)
            .set(noteB);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const provider = new document_link_provider_1.LinkProvider(ws, parser);
        const links = provider.provideDocumentLinks(doc);
        expect(links.length).toEqual(1);
        expect(links[0].target).toEqual(utility_commands_1.OPEN_COMMAND.asURI(noteB.uri));
    });
});
//# sourceMappingURL=document-link-provider.spec.js.map