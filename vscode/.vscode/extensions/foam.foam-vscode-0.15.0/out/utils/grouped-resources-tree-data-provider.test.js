"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const foam_core_1 = require("foam-core");
const utility_commands_1 = require("../features/utility-commands");
const settings_1 = require("../settings");
const test_utils_1 = require("../test/test-utils");
const grouped_resources_tree_data_provider_1 = require("./grouped-resources-tree-data-provider");
describe('GroupedResourcesTreeDataProvider', () => {
    const matchingNote1 = test_utils_1.createTestNote({ uri: '/path/ABC.md', title: 'ABC' });
    const matchingNote2 = test_utils_1.createTestNote({
        uri: '/path-bis/XYZ.md',
        title: 'XYZ',
    });
    const excludedPathNote = test_utils_1.createTestNote({
        uri: '/path-exclude/HIJ.m',
        title: 'HIJ',
    });
    const notMatchingNote = test_utils_1.createTestNote({
        uri: '/path-bis/ABCDEFG.md',
        title: 'ABCDEFG',
    });
    const workspace = new foam_core_1.FoamWorkspace()
        .set(matchingNote1)
        .set(matchingNote2)
        .set(excludedPathNote)
        .set(notMatchingNote);
    // Mock config
    const config = {
        exclude: ['path-exclude/**/*'],
        groupBy: settings_1.GroupedResoucesConfigGroupBy.Folder,
    };
    it('should return the grouped resources as a folder tree', async () => {
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('length3', 'note', config, [test_utils_1.strToUri('')], () => workspace
            .list()
            .filter(r => r.title.length === 3)
            .map(r => r.uri), uri => new grouped_resources_tree_data_provider_1.UriTreeItem(uri));
        const result = await provider.getChildren();
        expect(result).toMatchObject([
            {
                collapsibleState: 1,
                label: '/path',
                description: '1 note',
                children: [new grouped_resources_tree_data_provider_1.UriTreeItem(matchingNote1.uri)],
            },
            {
                collapsibleState: 1,
                label: '/path-bis',
                description: '1 note',
                children: [new grouped_resources_tree_data_provider_1.UriTreeItem(matchingNote2.uri)],
            },
        ]);
    });
    it('should return the grouped resources in a directory', async () => {
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('length3', 'note', config, [test_utils_1.strToUri('')], () => workspace
            .list()
            .filter(r => r.title.length === 3)
            .map(r => r.uri), uri => new grouped_resources_tree_data_provider_1.UriTreeItem(uri));
        const directory = new grouped_resources_tree_data_provider_1.DirectoryTreeItem('/path', [new grouped_resources_tree_data_provider_1.UriTreeItem(matchingNote1.uri)], 'note');
        const result = await provider.getChildren(directory);
        expect(result).toMatchObject([
            {
                collapsibleState: 0,
                label: 'ABC',
                description: '/path/ABC.md',
                command: { command: utility_commands_1.OPEN_COMMAND.command },
            },
        ]);
    });
    it('should return the flattened resources', async () => {
        const mockConfig = {
            ...config,
            groupBy: settings_1.GroupedResoucesConfigGroupBy.Off,
        };
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('length3', 'note', mockConfig, [test_utils_1.strToUri('')], () => workspace
            .list()
            .filter(r => r.title.length === 3)
            .map(r => r.uri), uri => new grouped_resources_tree_data_provider_1.UriTreeItem(uri));
        const result = await provider.getChildren();
        expect(result).toMatchObject([
            {
                collapsibleState: 0,
                label: matchingNote1.title,
                description: '/path/ABC.md',
                command: { command: utility_commands_1.OPEN_COMMAND.command },
            },
            {
                collapsibleState: 0,
                label: matchingNote2.title,
                description: '/path-bis/XYZ.md',
                command: { command: utility_commands_1.OPEN_COMMAND.command },
            },
        ]);
    });
    it('should return the grouped resources without exclusion', async () => {
        const mockConfig = { ...config, exclude: [] };
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('length3', 'note', mockConfig, [test_utils_1.strToUri('')], () => workspace
            .list()
            .filter(r => r.title.length === 3)
            .map(r => r.uri), uri => new grouped_resources_tree_data_provider_1.UriTreeItem(uri));
        const result = await provider.getChildren();
        expect(result).toMatchObject([
            expect.anything(),
            expect.anything(),
            {
                collapsibleState: 1,
                label: '/path-exclude',
                description: '1 note',
                children: [new grouped_resources_tree_data_provider_1.UriTreeItem(excludedPathNote.uri)],
            },
        ]);
    });
    it('should dynamically set the description', async () => {
        const description = 'test description';
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('length3', description, config, [test_utils_1.strToUri('')], () => workspace
            .list()
            .filter(r => r.title.length === 3)
            .map(r => r.uri), uri => new grouped_resources_tree_data_provider_1.UriTreeItem(uri));
        const result = await provider.getChildren();
        expect(result).toMatchObject([
            {
                collapsibleState: 1,
                label: '/path',
                description: `1 ${description}`,
                children: expect.anything(),
            },
            {
                collapsibleState: 1,
                label: '/path-bis',
                description: `1 ${description}`,
                children: expect.anything(),
            },
        ]);
    });
});
//# sourceMappingURL=grouped-resources-tree-data-provider.test.js.map