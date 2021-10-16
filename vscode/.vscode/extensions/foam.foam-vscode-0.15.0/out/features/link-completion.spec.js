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
const link_completion_1 = require("./link-completion");
describe('Link Completion', () => {
    const root = vscode.workspace.workspaceFolders[0].uri;
    const ws = new foam_core_1.FoamWorkspace();
    ws.set(test_utils_1.createTestNote({
        root,
        uri: 'file-name.md',
    }))
        .set(test_utils_1.createTestNote({
        root,
        uri: 'File name with spaces.md',
    }))
        .set(test_utils_1.createTestNote({
        root,
        uri: 'path/to/file.md',
        links: [{ slug: 'placeholder text' }],
    }));
    const graph = foam_core_1.FoamGraph.fromWorkspace(ws);
    beforeAll(async () => {
        await test_utils_1.cleanWorkspace();
    });
    afterAll(async () => {
        ws.dispose();
        graph.dispose();
        await test_utils_1.cleanWorkspace();
    });
    beforeEach(async () => {
        await test_utils_1.closeEditors();
    });
    it('should not return any link for empty documents', async () => {
        const { uri } = await test_utils_1.createFile('');
        const { doc } = await test_utils_1.showInEditor(uri);
        const provider = new link_completion_1.CompletionProvider(ws, graph);
        const links = await provider.provideCompletionItems(doc, new vscode.Position(0, 0));
        expect(links).toBeNull();
    });
    it('should return notes and placeholders', async () => {
        const { uri } = await test_utils_1.createFile('[[file]] [[');
        const { doc } = await test_utils_1.showInEditor(uri);
        const provider = new link_completion_1.CompletionProvider(ws, graph);
        const links = await provider.provideCompletionItems(doc, new vscode.Position(0, 11));
        expect(links.items.length).toEqual(4);
    });
    it('should not return link outside the wikilink brackets', async () => {
        const { uri } = await test_utils_1.createFile('[[file]] then');
        const { doc } = await test_utils_1.showInEditor(uri);
        const provider = new link_completion_1.CompletionProvider(ws, graph);
        const links = await provider.provideCompletionItems(doc, new vscode.Position(0, 12));
        expect(links).toBeNull();
    });
});
//# sourceMappingURL=link-completion.spec.js.map