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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DirectoryTreeItem = exports.ResourceTreeItem = exports.UriTreeItem = exports.GroupedResourcesTreeDataProvider = void 0;
const path = __importStar(require("path"));
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const micromatch_1 = __importDefault(require("micromatch"));
const settings_1 = require("../settings");
const utils_1 = require("../utils");
const utility_commands_1 = require("../features/utility-commands");
const vsc_utils_1 = require("./vsc-utils");
/**
 * Provides the ability to expose a TreeDataExplorerView in VSCode. This class will
 * iterate over each Resource in the FoamWorkspace, call the provided filter predicate, and
 * display the Resources.
 *
 * **NOTE**: In order for this provider to correctly function, you must define the following command in the package.json file:
   * ```
   * foam-vscode.group-${providerId}-by-folder
   * foam-vscode.group-${providerId}-off
   * ```
   * Where `providerId` is the same string provided to the constructor. You must also register the commands in your context subscriptions as follows:
   * ```
   * const provider = new GroupedResourcesTreeDataProvider(
      ...
    );
    context.subscriptions.push(
       vscode.window.registerTreeDataProvider(
       'foam-vscode.placeholders',
       provider
       ),
       ...provider.commands,
    );
    ```
 * @export
 * @class GroupedResourcesTreeDataProvider
 * @implements {vscode.TreeDataProvider<GroupedResourceTreeItem>}
 */
class GroupedResourcesTreeDataProvider {
    /**
     * Creates an instance of GroupedResourcesTreeDataProvider.
     * **NOTE**: In order for this provider to correctly function, you must define the following command in the package.json file:
     * ```
     * foam-vscode.group-${providerId}-by-folder
     * foam-vscode.group-${providerId}-off
     * ```
     * Where `providerId` is the same string provided to this constructor. You must also register the commands in your context subscriptions as follows:
     * ```
     * const provider = new GroupedResourcesTreeDataProvider(
        ...
      );
      context.subscriptions.push(
         vscode.window.registerTreeDataProvider(
         'foam-vscode.placeholders',
         provider
         ),
         ...provider.commands,
      );
      ```
     * @param {string} providerId A **unique** providerId, this will be used to generate necessary commands within the provider.
     * @param {string} resourceName A display name used in the explorer view
     * @param {() => Array<URI>} computeResources
     * @param {(item: URI) => GroupedResourceTreeItem} createTreeItem
     * @param {GroupedResourcesConfig} config
     * @param {URI[]} workspaceUris The workspace URIs
     * @memberof GroupedResourcesTreeDataProvider
     */
    constructor(providerId, resourceName, config, workspaceUris, computeResources, createTreeItem) {
        this.providerId = providerId;
        this.resourceName = resourceName;
        this.computeResources = computeResources;
        this.createTreeItem = createTreeItem;
        // prettier-ignore
        this._onDidChangeTreeData = new vscode.EventEmitter();
        // prettier-ignore
        this.onDidChangeTreeData = this._onDidChangeTreeData.event;
        // prettier-ignore
        this.groupBy = settings_1.GroupedResoucesConfigGroupBy.Folder;
        this.exclude = [];
        this.flatUris = [];
        this.root = vscode.workspace.workspaceFolders[0].uri.path;
        this.groupBy = config.groupBy;
        this.exclude = this.getGlobs(workspaceUris, config.exclude);
        this.setContext();
        this.doComputeResources();
    }
    get commands() {
        return [
            vscode.commands.registerCommand(`foam-vscode.group-${this.providerId}-by-folder`, () => this.setGroupBy(settings_1.GroupedResoucesConfigGroupBy.Folder)),
            vscode.commands.registerCommand(`foam-vscode.group-${this.providerId}-off`, () => this.setGroupBy(settings_1.GroupedResoucesConfigGroupBy.Off)),
        ];
    }
    setGroupBy(groupBy) {
        this.groupBy = groupBy;
        this.setContext();
        this.refresh();
    }
    setContext() {
        vscode.commands.executeCommand('setContext', `foam-vscode.${this.providerId}-grouped-by-folder`, this.groupBy === settings_1.GroupedResoucesConfigGroupBy.Folder);
    }
    refresh() {
        this.doComputeResources();
        this._onDidChangeTreeData.fire();
    }
    getTreeItem(item) {
        return item;
    }
    getChildren(directory) {
        if (this.groupBy === settings_1.GroupedResoucesConfigGroupBy.Folder) {
            if (utils_1.isSome(directory)) {
                return Promise.resolve(directory.children.sort(sortByTreeItemLabel));
            }
            const directories = Object.entries(this.getUrisByDirectory())
                .sort(([dir1], [dir2]) => sortByString(dir1, dir2))
                .map(([dir, children]) => new DirectoryTreeItem(dir, children.map(this.createTreeItem), this.resourceName));
            return Promise.resolve(directories);
        }
        const items = this.flatUris
            .map(uri => this.createTreeItem(uri))
            .sort(sortByTreeItemLabel);
        return Promise.resolve(items);
    }
    resolveTreeItem(item) {
        return item.resolveTreeItem();
    }
    doComputeResources() {
        this.flatUris = this.computeResources()
            .filter(uri => !this.isMatch(uri))
            .filter(utils_1.isSome);
    }
    isMatch(uri) {
        return micromatch_1.default.isMatch(foam_core_1.URI.toFsPath(uri), this.exclude);
    }
    getGlobs(fsURI, globs) {
        globs = globs.map(glob => (glob.startsWith('/') ? glob.slice(1) : glob));
        const exclude = [];
        for (const fsPath of fsURI) {
            let folder = fsPath.path.replace(/\\/g, '/');
            if (folder.substr(-1) === '/') {
                folder = folder.slice(0, -1);
            }
            exclude.push(...globs.map(g => `${folder}/${g}`));
        }
        return exclude;
    }
    getUrisByDirectory() {
        const resourcesByDirectory = {};
        for (const uri of this.flatUris) {
            const p = uri.path.replace(this.root, '');
            const { dir } = path.parse(p);
            if (resourcesByDirectory[dir]) {
                resourcesByDirectory[dir].push(uri);
            }
            else {
                resourcesByDirectory[dir] = [uri];
            }
        }
        return resourcesByDirectory;
    }
}
exports.GroupedResourcesTreeDataProvider = GroupedResourcesTreeDataProvider;
class UriTreeItem extends vscode.TreeItem {
    constructor(uri, options = {}) {
        var _a, _b, _c;
        super((_a = options === null || options === void 0 ? void 0 : options.title) !== null && _a !== void 0 ? _a : foam_core_1.URI.getBasename(uri), options.collapsibleState);
        this.uri = uri;
        this.description = uri.path.replace((_b = vscode.workspace.getWorkspaceFolder(vsc_utils_1.toVsCodeUri(uri))) === null || _b === void 0 ? void 0 : _b.uri.path, '');
        this.tooltip = undefined;
        this.command = {
            command: utility_commands_1.OPEN_COMMAND.command,
            title: utility_commands_1.OPEN_COMMAND.title,
            arguments: [
                {
                    uri: uri,
                },
            ],
        };
        this.iconPath = new vscode.ThemeIcon((_c = options.icon) !== null && _c !== void 0 ? _c : 'new-file');
    }
    resolveTreeItem() {
        return Promise.resolve(this);
    }
}
exports.UriTreeItem = UriTreeItem;
class ResourceTreeItem extends UriTreeItem {
    constructor(resource, workspace, collapsibleState = vscode.TreeItemCollapsibleState.None) {
        super(resource.uri, {
            title: resource.title,
            icon: 'note',
            collapsibleState,
        });
        this.resource = resource;
        this.workspace = workspace;
        this.contextValue = 'resource';
    }
    async resolveTreeItem() {
        if (this instanceof ResourceTreeItem) {
            const content = await this.workspace.readAsMarkdown(this.resource.uri);
            this.tooltip = utils_1.isSome(content)
                ? utils_1.getNoteTooltip(content)
                : this.resource.title;
        }
        return this;
    }
}
exports.ResourceTreeItem = ResourceTreeItem;
class DirectoryTreeItem extends vscode.TreeItem {
    constructor(dir, children, itemLabel) {
        super(dir || 'Not Created', vscode.TreeItemCollapsibleState.Collapsed);
        this.dir = dir;
        this.children = children;
        this.iconPath = new vscode.ThemeIcon('folder');
        this.contextValue = 'directory';
        const s = this.children.length > 1 ? 's' : '';
        this.description = `${this.children.length} ${itemLabel}${s}`;
    }
    resolveTreeItem() {
        const titles = this.children
            .map(c => { var _a; return (_a = c.label) === null || _a === void 0 ? void 0 : _a.toString(); })
            .sort(sortByString);
        this.tooltip = utils_1.getContainsTooltip(titles);
        return Promise.resolve(this);
    }
}
exports.DirectoryTreeItem = DirectoryTreeItem;
const sortByTreeItemLabel = (a, b) => a.label.toString().localeCompare(b.label.toString());
const sortByString = (a, b) => a.toLocaleLowerCase().localeCompare(b.toLocaleLowerCase());
//# sourceMappingURL=grouped-resources-tree-data-provider.js.map