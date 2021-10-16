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
exports.HoverProvider = exports.CONFIG_KEY = void 0;
const vscode = __importStar(require("vscode"));
const foam_core_1 = require("foam-core");
const utils_1 = require("../utils");
const vsc_utils_1 = require("../utils/vsc-utils");
const config_1 = require("../services/config");
exports.CONFIG_KEY = 'links.hover.enable';
const feature = {
    activate: async (context, foamPromise) => {
        const isHoverEnabled = config_1.monitorFoamVsCodeConfig(exports.CONFIG_KEY);
        const foam = await foamPromise;
        context.subscriptions.push(isHoverEnabled, vscode.languages.registerHoverProvider(utils_1.mdDocSelector, new HoverProvider(isHoverEnabled, foam.workspace, foam.services.parser)));
    },
};
class HoverProvider {
    constructor(isHoverEnabled, workspace, parser) {
        this.isHoverEnabled = isHoverEnabled;
        this.workspace = workspace;
        this.parser = parser;
    }
    async provideHover(document, position, token) {
        if (!this.isHoverEnabled()) {
            return;
        }
        const startResource = this.parser.parse(document.uri, document.getText());
        const targetLink = startResource.links.find(link => foam_core_1.Range.containsPosition(link.range, {
            line: position.line,
            character: position.character,
        }));
        if (!targetLink) {
            return;
        }
        const targetUri = this.workspace.resolveLink(startResource, targetLink);
        if (foam_core_1.URI.isPlaceholder(targetUri)) {
            return;
        }
        const content = await this.workspace.readAsMarkdown(targetUri);
        const md = utils_1.isSome(content)
            ? utils_1.getNoteTooltip(content)
            : this.workspace.get(targetUri).title;
        const hover = {
            contents: [md],
            range: vsc_utils_1.toVsCodeRange(targetLink.range),
        };
        return hover;
    }
}
exports.HoverProvider = HoverProvider;
exports.default = feature;
//# sourceMappingURL=hover-provider.js.map