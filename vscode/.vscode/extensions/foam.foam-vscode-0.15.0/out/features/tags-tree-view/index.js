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
exports.TagReference = exports.TagSearch = exports.TagItem = exports.TagsProvider = void 0;
const vscode = __importStar(require("vscode"));
const utils_1 = require("../../utils");
const vsc_utils_1 = require("../../utils/vsc-utils");
const TAG_SEPARATOR = '/';
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        const provider = new TagsProvider(foam, foam.workspace);
        context.subscriptions.push(vscode.window.registerTreeDataProvider('foam-vscode.tags-explorer', provider));
        foam.workspace.onDidUpdate(() => provider.refresh());
        foam.workspace.onDidAdd(() => provider.refresh());
        foam.workspace.onDidDelete(() => provider.refresh());
    },
};
exports.default = feature;
class TagsProvider {
    constructor(foam, workspace) {
        this.foam = foam;
        this.workspace = workspace;
        // prettier-ignore
        this._onDidChangeTreeData = new vscode.EventEmitter();
        // prettier-ignore
        this.onDidChangeTreeData = this._onDidChangeTreeData.event;
        this.computeTags();
    }
    refresh() {
        this.computeTags();
        this._onDidChangeTreeData.fire();
    }
    computeTags() {
        this.tags = [...this.foam.tags.tags]
            .map(([tag, notes]) => ({ tag, notes }))
            .sort((a, b) => a.tag.localeCompare(b.tag));
    }
    getTreeItem(element) {
        return element;
    }
    getChildren(element) {
        if (element) {
            const nestedTagItems = this.tags
                .filter(item => item.tag.indexOf(element.title + TAG_SEPARATOR) > -1)
                .map(item => new TagItem(item.tag, item.tag.substring(item.tag.indexOf(TAG_SEPARATOR) + 1), item.notes))
                .sort((a, b) => a.title.localeCompare(b.title));
            const references = element.notes
                .map(uri => this.foam.workspace.get(uri))
                .reduce((acc, note) => {
                const tags = note.tags.filter(t => t.label === element.tag);
                return [
                    ...acc,
                    ...tags.slice(0, 1).map(t => new TagReference(t, note)),
                ];
            }, [])
                .sort((a, b) => a.title.localeCompare(b.title));
            return Promise.resolve([
                new TagSearch(element.tag),
                ...nestedTagItems,
                ...references,
            ]);
        }
        if (!element) {
            const tags = this.tags
                .map(({ tag, notes }) => {
                const parentTag = tag.indexOf(TAG_SEPARATOR) > 0
                    ? tag.substring(0, tag.indexOf(TAG_SEPARATOR))
                    : tag;
                return new TagItem(parentTag, parentTag, notes);
            })
                .filter((value, index, array) => array.findIndex(tag => tag.title === value.title) === index);
            return Promise.resolve(tags.sort((a, b) => a.tag.localeCompare(b.tag)));
        }
    }
    async resolveTreeItem(item) {
        if (item instanceof TagReference) {
            const content = await this.workspace.read(item.note.uri);
            if (utils_1.isSome(content)) {
                item.tooltip = utils_1.getNoteTooltip(content);
            }
        }
        return item;
    }
}
exports.TagsProvider = TagsProvider;
class TagItem extends vscode.TreeItem {
    constructor(tag, title, notes) {
        super(title, vscode.TreeItemCollapsibleState.Collapsed);
        this.tag = tag;
        this.title = title;
        this.notes = notes;
        this.iconPath = new vscode.ThemeIcon('symbol-number');
        this.contextValue = 'tag';
        this.description = `${this.notes.length} reference${this.notes.length !== 1 ? 's' : ''}`;
    }
}
exports.TagItem = TagItem;
class TagSearch extends vscode.TreeItem {
    constructor(tag) {
        super(`Search #${tag}`, vscode.TreeItemCollapsibleState.None);
        this.tag = tag;
        this.iconPath = new vscode.ThemeIcon('search');
        this.contextValue = 'tag-search';
        const searchString = `#${tag}`;
        this.tooltip = `Search ${searchString} in workspace`;
        this.command = {
            command: 'workbench.action.findInFiles',
            arguments: [
                {
                    query: searchString,
                    triggerSearch: true,
                    matchWholeWord: true,
                    isCaseSensitive: true,
                },
            ],
            title: 'Search',
        };
    }
}
exports.TagSearch = TagSearch;
class TagReference extends vscode.TreeItem {
    constructor(tag, note) {
        var _a;
        super(note.title, vscode.TreeItemCollapsibleState.None);
        this.tag = tag;
        this.note = note;
        this.iconPath = new vscode.ThemeIcon('note');
        this.contextValue = 'reference';
        this.title = note.title;
        this.description = note.uri.path.replace((_a = vscode.workspace.getWorkspaceFolder(vsc_utils_1.toVsCodeUri(note.uri))) === null || _a === void 0 ? void 0 : _a.uri.path, '');
        this.tooltip = undefined;
        this.command = {
            command: 'vscode.open',
            arguments: [
                note.uri,
                {
                    preview: true,
                    selection: vsc_utils_1.toVsCodeRange(tag.range),
                },
            ],
            title: 'Open File',
        };
    }
}
exports.TagReference = TagReference;
//# sourceMappingURL=index.js.map