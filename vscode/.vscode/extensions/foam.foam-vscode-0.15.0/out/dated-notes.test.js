"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const dated_notes_1 = require("./dated-notes");
const foam_core_1 = require("foam-core");
const utils_1 = require("./utils");
describe('getDailyNotePath', () => {
    const date = new Date('2021-02-07T00:00:00Z');
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const isoDate = `${year}-0${month}-0${day}`;
    test('Adds the root directory to relative directories', async () => {
        const config = 'journal';
        const expectedPath = foam_core_1.URI.joinPath(vscode_1.workspace.workspaceFolders[0].uri, config, `${isoDate}.md`);
        await vscode_1.workspace
            .getConfiguration('foam')
            .update('openDailyNote.directory', config);
        const foamConfiguration = vscode_1.workspace.getConfiguration('foam');
        expect(foam_core_1.URI.toFsPath(dated_notes_1.getDailyNotePath(foamConfiguration, date))).toEqual(foam_core_1.URI.toFsPath(expectedPath));
    });
    test('Uses absolute directories without modification', async () => {
        const config = utils_1.isWindows
            ? 'c:\\absolute_path\\journal'
            : '/absolute_path/journal';
        const expectedPath = utils_1.isWindows
            ? `${config}\\${isoDate}.md`
            : `${config}/${isoDate}.md`;
        await vscode_1.workspace
            .getConfiguration('foam')
            .update('openDailyNote.directory', config);
        const foamConfiguration = vscode_1.workspace.getConfiguration('foam');
        expect(foam_core_1.URI.toFsPath(dated_notes_1.getDailyNotePath(foamConfiguration, date))).toMatch(expectedPath);
    });
});
//# sourceMappingURL=dated-notes.test.js.map