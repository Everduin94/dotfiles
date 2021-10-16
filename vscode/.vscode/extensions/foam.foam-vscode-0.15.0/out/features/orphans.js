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
exports.isOrphan = void 0;
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const settings_1 = require("../settings");
const grouped_resources_tree_data_provider_1 = require("../utils/grouped-resources-tree-data-provider");
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        const workspacesURIs = vscode.workspace.workspaceFolders.map(dir => dir.uri);
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('orphans', 'orphan', settings_1.getOrphansConfig(), workspacesURIs, () => foam.graph.getAllNodes().filter(uri => exports.isOrphan(uri, foam.graph)), uri => {
            if (foam_core_1.URI.isPlaceholder(uri)) {
                return new grouped_resources_tree_data_provider_1.UriTreeItem(uri);
            }
            const resource = foam.workspace.find(uri);
            return new grouped_resources_tree_data_provider_1.ResourceTreeItem(resource, foam.workspace);
        });
        context.subscriptions.push(vscode.window.registerTreeDataProvider('foam-vscode.orphans', provider), ...provider.commands, foam.workspace.onDidAdd(() => provider.refresh()), foam.workspace.onDidUpdate(() => provider.refresh()), foam.workspace.onDidDelete(() => provider.refresh()));
    },
};
exports.isOrphan = (uri, graph) => graph.getConnections(uri).length === 0;
exports.default = feature;
//# sourceMappingURL=orphans.js.map