"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const foam_core_1 = require("foam-core");
const test_utils_1 = require("../test/test-utils");
const backlinks_1 = require("./backlinks");
const utility_commands_1 = require("./utility-commands");
const vsc_utils_1 = require("../utils/vsc-utils");
describe('Backlinks panel', () => {
    beforeAll(async () => {
        await test_utils_1.cleanWorkspace();
        await test_utils_1.createNote(noteA);
        await test_utils_1.createNote(noteB);
        await test_utils_1.createNote(noteC);
    });
    afterAll(async () => {
        graph.dispose();
        ws.dispose();
        await test_utils_1.cleanWorkspace();
    });
    const rootUri = vscode_1.workspace.workspaceFolders[0].uri;
    const ws = test_utils_1.createTestWorkspace();
    const noteA = test_utils_1.createTestNote({
        root: rootUri,
        uri: './note-a.md',
    });
    const noteB = test_utils_1.createTestNote({
        root: rootUri,
        uri: './note-b.md',
        links: [{ slug: 'note-a' }, { slug: 'note-a' }],
    });
    const noteC = test_utils_1.createTestNote({
        root: rootUri,
        uri: './note-c.md',
        links: [{ slug: 'note-a' }],
    });
    ws.set(noteA)
        .set(noteB)
        .set(noteC);
    const graph = foam_core_1.FoamGraph.fromWorkspace(ws, true);
    const provider = new backlinks_1.BacklinksTreeDataProvider(ws, graph);
    beforeEach(async () => {
        await test_utils_1.closeEditors();
        provider.target = undefined;
    });
    // Skipping these as still figuring out how to interact with the provider
    // running in the test instance of VS Code
    it.skip('does not target excluded files', async () => {
        provider.target = foam_core_1.URI.file('/excluded-file.txt');
        expect(await provider.getChildren()).toEqual([]);
    });
    it.skip('targets active editor', async () => {
        const docA = await vscode_1.workspace.openTextDocument(vsc_utils_1.toVsCodeUri(noteA.uri));
        const docB = await vscode_1.workspace.openTextDocument(vsc_utils_1.toVsCodeUri(noteB.uri));
        await vscode_1.window.showTextDocument(docA);
        expect(provider.target).toEqual(noteA.uri);
        await vscode_1.window.showTextDocument(docB);
        expect(provider.target).toEqual(noteB.uri);
    });
    it('shows linking resources alphaetically by name', async () => {
        provider.target = noteA.uri;
        const notes = (await provider.getChildren());
        expect(notes.map(n => n.resource.uri.path)).toEqual([
            noteB.uri.path,
            noteC.uri.path,
        ]);
    });
    it('shows references in range order', async () => {
        provider.target = noteA.uri;
        const notes = (await provider.getChildren());
        const linksFromB = (await provider.getChildren(notes[0]));
        expect(linksFromB.map(l => l.link)).toEqual(noteB.links.sort((a, b) => a.range.start.character - b.range.start.character));
    });
    it('navigates to the document if clicking on note', async () => {
        provider.target = noteA.uri;
        const notes = (await provider.getChildren());
        expect(notes[0].command).toMatchObject({
            command: utility_commands_1.OPEN_COMMAND.command,
            arguments: [expect.objectContaining({ uri: noteB.uri })],
        });
    });
    it('navigates to document with link selection if clicking on backlink', async () => {
        provider.target = noteA.uri;
        const notes = (await provider.getChildren());
        const linksFromB = (await provider.getChildren(notes[0]));
        expect(linksFromB[0].command).toMatchObject({
            command: 'vscode.open',
            arguments: [
                noteB.uri,
                {
                    selection: expect.arrayContaining([]),
                },
            ],
        });
    });
    it('refreshes upon changes in the workspace', async () => {
        let notes = [];
        provider.target = noteA.uri;
        notes = (await provider.getChildren());
        expect(notes.length).toEqual(2);
        const noteD = test_utils_1.createTestNote({
            root: rootUri,
            uri: './note-d.md',
        });
        ws.set(noteD);
        notes = (await provider.getChildren());
        expect(notes.length).toEqual(2);
        const noteDBis = test_utils_1.createTestNote({
            root: rootUri,
            uri: './note-d.md',
            links: [{ slug: 'note-a' }],
        });
        ws.set(noteDBis);
        notes = (await provider.getChildren());
        expect(notes.length).toEqual(3);
        expect(notes.map(n => n.resource.uri.path)).toEqual([noteB.uri, noteC.uri, noteD.uri].map(uri => uri.path));
    });
});
//# sourceMappingURL=backlinks.spec.js.map