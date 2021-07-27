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
exports.isPlaceholderResource = void 0;
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const settings_1 = require("../settings");
const grouped_resources_tree_data_provider_1 = require("../utils/grouped-resources-tree-data-provider");
const feature = {
    activate: async (context, foamPromise) => {
        const foam = await foamPromise;
        const workspacesURIs = vscode.workspace.workspaceFolders.map(dir => dir.uri);
        const provider = new grouped_resources_tree_data_provider_1.GroupedResourcesTreeDataProvider('placeholders', 'placeholder', settings_1.getPlaceholdersConfig(), workspacesURIs, () => foam.graph
            .getAllNodes()
            .filter(uri => isPlaceholderResource(uri, foam.workspace)), uri => {
            if (foam_core_1.URI.isPlaceholder(uri)) {
                return new grouped_resources_tree_data_provider_1.UriTreeItem(uri);
            }
            const resource = foam.workspace.find(uri);
            return new grouped_resources_tree_data_provider_1.ResourceTreeItem(resource, foam.workspace);
        });
        context.subscriptions.push(vscode.window.registerTreeDataProvider('foam-vscode.placeholders', provider), ...provider.commands, foam.workspace.onDidAdd(() => provider.refresh()), foam.workspace.onDidUpdate(() => provider.refresh()), foam.workspace.onDidDelete(() => provider.refresh()));
    },
};
exports.default = feature;
function isPlaceholderResource(uri, workspace) {
    var _a;
    if (foam_core_1.URI.isPlaceholder(uri)) {
        return true;
    }
    const resource = workspace.find(uri);
    const contentLines = (_a = resource === null || resource === void 0 ? void 0 : resource.source.text.trim().split('\n').map(line => line.trim()).filter(line => line.length > 0).filter(line => !line.startsWith('#'))) !== null && _a !== void 0 ? _a : '';
    return contentLines.length === 0;
}
exports.isPlaceholderResource = isPlaceholderResource;
//# sourceMappingURL=placeholders.js.map