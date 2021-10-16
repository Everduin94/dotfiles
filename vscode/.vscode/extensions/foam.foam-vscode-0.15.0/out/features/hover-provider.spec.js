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
const hover_provider_1 = require("./hover-provider");
describe('Hover provider', () => {
    const noCancelToken = {
        isCancellationRequested: false,
        onCancellationRequested: null,
    };
    const parser = foam_core_1.createMarkdownParser([]);
    const hoverEnabled = () => true;
    // We can't use createTestWorkspace from /packages/foam-vscode/src/test/test-utils.ts
    // because we need a fully instantiated MarkdownResourceProvider (with a real instance of ResourceParser).
    const createWorkspace = () => {
        const matcher = new foam_core_1.Matcher([foam_core_1.URI.file('/')], ['**/*']);
        const resourceProvider = new foam_core_1.MarkdownResourceProvider(matcher);
        const workspace = new foam_core_1.FoamWorkspace();
        workspace.registerProvider(resourceProvider);
        return workspace;
    };
    const fileContent = `# File B Title
  ---
  tags: my-tag1 my-tag2
  ---

The content of file B
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddddddddddddddddddddddd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee`;
    // Fixture needed as long tests are running with vscode 1.53.0 (MarkdownString is not available)
    const simpleTooltipExpectedFormat = 'File B Title --- tags: my-tag1 my-tag2 --- The content of file B aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ' +
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb cccccccccccccccccccccccccccccccccccccccc dddddddddddd...';
    // Fixture to use when tests are running with vscode version >= STABLE_MARKDOWN_STRING_API_VERSION (1.52.1)
    /*const markdownTooltipExpectedFormat = `# File B Title
    ---
    tags: my-tag1 my-tag2
    ---
  
  The content of file B
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
  cccccccccccccccccccccccccccccccccccccccc
  dddddddddddddddddddddddddddddddddddddddd
  eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee`;*/
    beforeAll(async () => {
        await test_utils_1.cleanWorkspace();
    });
    afterAll(async () => {
        await test_utils_1.cleanWorkspace();
    });
    beforeEach(async () => {
        await test_utils_1.closeEditors();
    });
    it('should not return hover content for empty documents', async () => {
        const { uri, content } = await test_utils_1.createFile('');
        const ws = createWorkspace().set(parser.parse(uri, content));
        const provider = new hover_provider_1.HoverProvider(hoverEnabled, ws, parser);
        const doc = await vscode.workspace.openTextDocument(uri);
        const pos = new vscode.Position(0, 0);
        const result = await provider.provideHover(doc, pos, noCancelToken);
        expect(result).toBeUndefined();
    });
    it('should not return hover content for documents without links', async () => {
        const { uri, content } = await test_utils_1.createFile('This is some content without links');
        const ws = createWorkspace().set(parser.parse(uri, content));
        const provider = new hover_provider_1.HoverProvider(hoverEnabled, ws, parser);
        const doc = await vscode.workspace.openTextDocument(uri);
        const pos = new vscode.Position(0, 0);
        const result = await provider.provideHover(doc, pos, noCancelToken);
        expect(result).toBeUndefined();
    });
    it('should return hover content for a wikilink', async () => {
        const fileB = await test_utils_1.createFile(fileContent);
        const fileA = await test_utils_1.createFile(`this is a link to [[${fileB.name}]] end of the line.`);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const noteB = parser.parse(fileB.uri, fileB.content);
        const ws = createWorkspace()
            .set(noteA)
            .set(noteB);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const pos = new vscode.Position(0, 22); // Set cursor position on the wikilink.
        const providerNotEnabled = new hover_provider_1.HoverProvider(() => false, ws, parser);
        expect(await providerNotEnabled.provideHover(doc, pos, noCancelToken)).toBeUndefined();
        const provider = new hover_provider_1.HoverProvider(hoverEnabled, ws, parser);
        const result = await provider.provideHover(doc, pos, noCancelToken);
        expect(result.contents).toHaveLength(1);
        const content = result.contents[0];
        // As long as the tests are running with vscode 1.53.0 , MarkdownString is not available.
        // See file://./../test/run-tests.ts and getNoteTooltip at file://./../utils.ts
        expect(content).toEqual(simpleTooltipExpectedFormat);
        // If vscode test version >= STABLE_MARKDOWN_STRING_API_VERSION (1.52.1)
        // expect((content as vscode.MarkdownString).value).toEqual(markdownTooltipExpectedFormat);
    });
    it('should return hover content for a regular link', async () => {
        const fileB = await test_utils_1.createFile(fileContent);
        const fileA = await test_utils_1.createFile(`this is a link to [a file](./${fileB.base}).`);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const noteB = parser.parse(fileB.uri, fileB.content);
        const ws = createWorkspace()
            .set(noteA)
            .set(noteB);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const pos = new vscode.Position(0, 22); // Set cursor position on the link.
        const provider = new hover_provider_1.HoverProvider(hoverEnabled, ws, parser);
        const result = await provider.provideHover(doc, pos, noCancelToken);
        expect(result.contents).toHaveLength(1);
        const content = result.contents[0];
        // As long as the tests are running with vscode 1.53.0 , MarkdownString is not available.
        // See file://./../test/run-tests.ts and getNoteTooltip at file://./../utils.ts
        expect(content).toEqual(simpleTooltipExpectedFormat);
        // If vscode test version >= STABLE_MARKDOWN_STRING_API_VERSION (1.52.1)
        // expect((content as vscode.MarkdownString).value).toEqual(markdownTooltipExpectedFormat);
    });
    it('should not return hover content when the cursor is not placed on a wikilink', async () => {
        const fileB = await test_utils_1.createFile('# File B\nThe content of file B');
        const fileA = await test_utils_1.createFile(`this is a link to [[${fileB.name}]] end of the line.`);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const noteB = parser.parse(fileB.uri, fileB.content);
        const ws = createWorkspace()
            .set(noteA)
            .set(noteB);
        const provider = new hover_provider_1.HoverProvider(hoverEnabled, ws, parser);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const pos = new vscode.Position(0, 11); // Set cursor position beside the wikilink.
        const result = await provider.provideHover(doc, pos, noCancelToken);
        expect(result).toBeUndefined();
    });
    it('should not return hover content for a placeholder', async () => {
        const fileA = await test_utils_1.createFile(`this is a link to [[a placeholder]] end of the line.`);
        const noteA = parser.parse(fileA.uri, fileA.content);
        const ws = createWorkspace().set(noteA);
        const provider = new hover_provider_1.HoverProvider(hoverEnabled, ws, parser);
        const { doc } = await test_utils_1.showInEditor(noteA.uri);
        const pos = new vscode.Position(0, 22); // Set cursor position on the placeholder.
        const result = await provider.provideHover(doc, pos, noCancelToken);
        expect(result).toBeUndefined();
    });
});
//# sourceMappingURL=hover-provider.spec.js.map