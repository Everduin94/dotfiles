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
exports.BacklinkTreeItem = exports.BacklinksTreeDataProvider = void 0;
const vscode = __importStar(require("vscode"));
const lodash_1 = require("lodash");
const foam_core_1 = require("foam-core");
const utils_1 = require("../utils");
const grouped_resources_tree_data_provider_1 = require("../utils/grouped-resources-tree-data-provider");
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        const provider = new BacklinksTreeDataProvider(foam.workspace, foam.graph);
        vscode.window.onDidChangeActiveTextEditor(async () => {
            var _a;
            provider.target = (_a = vscode.window.activeTextEditor) === null || _a === void 0 ? void 0 : _a.document.uri;
            await provider.refresh();
        });
        context.subscriptions.push(vscode.window.registerTreeDataProvider('foam-vscode.backlinks', provider), foam.workspace.onDidAdd(() => provider.refresh()), foam.workspace.onDidUpdate(() => provider.refresh()), foam.workspace.onDidDelete(() => provider.refresh()));
    },
};
exports.default = feature;
class BacklinksTreeDataProvider {
    constructor(workspace, graph) {
        this.workspace = workspace;
        this.graph = graph;
        this.target = undefined;
        // prettier-ignore
        this._onDidChangeTreeDataEmitter = new vscode.EventEmitter();
        this.onDidChangeTreeData = this._onDidChangeTreeDataEmitter.event;
    }
    refresh() {
        this._onDidChangeTreeDataEmitter.fire();
    }
    getTreeItem(item) {
        return item;
    }
    getChildren(item) {
        const uri = this.target;
        if (item) {
            const resource = item.resource;
            const backlinkRefs = Promise.all(resource.links
                .filter(link => foam_core_1.URI.isEqual(this.workspace.resolveLink(resource, link), uri))
                .map(async (link) => {
                var _a;
                const item = new BacklinkTreeItem(resource, link);
                const lines = ((_a = (await this.workspace.read(resource.uri))) !== null && _a !== void 0 ? _a : '').split('\n');
                if (link.range.start.line < lines.length) {
                    const line = lines[link.range.start.line];
                    let start = Math.max(0, link.range.start.character - 15);
                    const ellipsis = start === 0 ? '' : '...';
                    item.label = `${link.range.start.line}: ${ellipsis}${line.substr(start, 300)}`;
                    item.tooltip = utils_1.getNoteTooltip(line);
                }
                return item;
            }));
            return backlinkRefs;
        }
        if (utils_1.isNone(uri) || utils_1.isNone(this.workspace.find(uri))) {
            return Promise.resolve([]);
        }
        const backlinksByResourcePath = lodash_1.groupBy(this.graph.getConnections(uri).filter(c => foam_core_1.URI.isEqual(c.target, uri)), b => b.source.path);
        const resources = Object.keys(backlinksByResourcePath)
            .map(res => backlinksByResourcePath[res][0].source)
            .map(uri => this.workspace.get(uri))
            .sort(foam_core_1.Resource.sortByTitle)
            .map(note => {
            const connections = backlinksByResourcePath[note.uri.path].sort((a, b) => foam_core_1.Range.isBefore(a.link.range, b.link.range));
            const item = new grouped_resources_tree_data_provider_1.ResourceTreeItem(note, this.workspace, vscode.TreeItemCollapsibleState.Expanded);
            item.description = `(${connections.length}) ${item.description}`;
            return item;
        });
        return Promise.resolve(resources);
    }
    resolveTreeItem(item) {
        return item.resolveTreeItem();
    }
}
exports.BacklinksTreeDataProvider = BacklinksTreeDataProvider;
class BacklinkTreeItem extends vscode.TreeItem {
    constructor(resource, link) {
        super(link.label, vscode.TreeItemCollapsibleState.None);
        this.resource = resource;
        this.link = link;
        this.label = `${link.range.start.line}: ${this.label}`;
        this.command = {
            command: 'vscode.open',
            arguments: [resource.uri, { selection: link.range }],
            title: 'Go to link',
        };
    }
    resolveTreeItem() {
        return Promise.resolve(this);
    }
}
exports.BacklinkTreeItem = BacklinkTreeItem;
//# sourceMappingURL=backlinks.js.map