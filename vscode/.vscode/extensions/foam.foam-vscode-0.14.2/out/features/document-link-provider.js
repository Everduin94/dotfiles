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
exports.LinkProvider = void 0;
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const utils_1 = require("../utils");
const utility_commands_1 = require("./utility-commands");
const vsc_utils_1 = require("../utils/vsc-utils");
const config_1 = require("../services/config");
const feature = {
    activate: async (context, foamPromise) => {
        if (!config_1.getFoamVsCodeConfig('links.navigation.enable')) {
            return;
        }
        const foam = await foamPromise;
        context.subscriptions.push(vscode.languages.registerDocumentLinkProvider(utils_1.mdDocSelector, new LinkProvider(foam.workspace, foam.services.parser)));
    },
};
class LinkProvider {
    constructor(workspace, parser) {
        this.workspace = workspace;
        this.parser = parser;
    }
    provideDocumentLinks(document) {
        const resource = this.parser.parse(document.uri, document.getText());
        return resource.links.map(link => {
            const target = this.workspace.resolveLink(resource, link);
            const command = utility_commands_1.OPEN_COMMAND.asURI(vsc_utils_1.toVsCodeUri(target));
            const documentLink = new vscode.DocumentLink(vsc_utils_1.toVsCodeRange(link.range), command);
            documentLink.tooltip = foam_core_1.URI.isPlaceholder(target)
                ? `Create note for '${target.path}'`
                : `Go to ${foam_core_1.URI.toFsPath(target)}`;
            return documentLink;
        });
    }
}
exports.LinkProvider = LinkProvider;
exports.default = feature;
//# sourceMappingURL=document-link-provider.js.map