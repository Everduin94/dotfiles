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
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const foam_core_1 = require("foam-core");
const util_1 = require("util");
const settings_1 = require("../settings");
const utils_1 = require("../utils");
const feature = {
    activate: (context, foamPromise) => {
        let panel = undefined;
        vscode.workspace.onDidChangeConfiguration(event => {
            if (event.affectsConfiguration('foam.graph.style')) {
                const style = settings_1.getGraphStyle();
                panel.webview.postMessage({
                    type: 'didUpdateStyle',
                    payload: style,
                });
            }
        });
        vscode.commands.registerCommand('foam-vscode.show-graph', async () => {
            if (panel) {
                const columnToShowIn = vscode.window.activeTextEditor
                    ? vscode.window.activeTextEditor.viewColumn
                    : undefined;
                panel.reveal(columnToShowIn);
            }
            else {
                const foam = await foamPromise;
                panel = await createGraphPanel(foam, context);
                const onFoamChanged = _ => {
                    updateGraph(panel, foam);
                };
                const noteAddedListener = foam.workspace.onDidAdd(onFoamChanged);
                const noteUpdatedListener = foam.workspace.onDidUpdate(onFoamChanged);
                const noteDeletedListener = foam.workspace.onDidDelete(onFoamChanged);
                panel.onDidDispose(() => {
                    noteAddedListener.dispose();
                    noteUpdatedListener.dispose();
                    noteDeletedListener.dispose();
                    panel = undefined;
                });
                vscode.window.onDidChangeActiveTextEditor(e => {
                    if (e.document.uri.scheme === 'file') {
                        const note = foam.workspace.get(e.document.uri);
                        if (utils_1.isSome(note)) {
                            panel.webview.postMessage({
                                type: 'didSelectNote',
                                payload: note.uri.path,
                            });
                        }
                    }
                });
            }
        });
    },
};
function updateGraph(panel, foam) {
    const graph = generateGraphData(foam);
    panel.webview.postMessage({
        type: 'didUpdateGraphData',
        payload: graph,
    });
}
function generateGraphData(foam) {
    const graph = {
        nodes: {},
        edges: new Set(),
    };
    foam.workspace.list().forEach(n => {
        var _a;
        const type = n.type === 'note' ? (_a = n.properties.type) !== null && _a !== void 0 ? _a : 'note' : n.type;
        const title = n.type === 'note' ? n.title : path.basename(n.uri.path);
        graph.nodes[n.uri.path] = {
            id: n.uri.path,
            type: type,
            uri: n.uri,
            title: cutTitle(title),
            properties: n.properties,
            tags: n.tags,
        };
    });
    foam.graph.getAllConnections().forEach(c => {
        graph.edges.add({
            source: c.source.path,
            target: c.target.path,
        });
        if (foam_core_1.URI.isPlaceholder(c.target)) {
            graph.nodes[c.target.path] = {
                id: c.target.path,
                type: 'placeholder',
                uri: c.target,
                title: c.target.path,
                properties: {},
            };
        }
    });
    return {
        nodes: graph.nodes,
        links: Array.from(graph.edges),
    };
}
function cutTitle(title) {
    const maxLen = settings_1.getTitleMaxLength();
    if (maxLen > 0 && title.length > maxLen) {
        return title.substring(0, maxLen).concat('...');
    }
    return title;
}
async function createGraphPanel(foam, context) {
    const panel = vscode.window.createWebviewPanel('foam-graph', 'Foam Graph', vscode.ViewColumn.Two, {
        enableScripts: true,
        retainContextWhenHidden: true,
    });
    panel.webview.html = await getWebviewContent(context, panel);
    panel.webview.onDidReceiveMessage(async (message) => {
        switch (message.type) {
            case 'webviewDidLoad':
                const styles = settings_1.getGraphStyle();
                panel.webview.postMessage({
                    type: 'didUpdateStyle',
                    payload: styles,
                });
                updateGraph(panel, foam);
                break;
            case 'webviewDidSelectNode':
                const noteUri = vscode.Uri.parse(message.payload);
                const selectedNote = foam.workspace.get(noteUri);
                if (utils_1.isSome(selectedNote)) {
                    const doc = await vscode.workspace.openTextDocument(selectedNote.uri.path // vscode doesn't recognize the URI directly
                    );
                    vscode.window.showTextDocument(doc, vscode.ViewColumn.One);
                }
                break;
            case 'error':
                foam_core_1.Logger.error('An error occurred in the graph view', message.payload);
                break;
        }
    }, undefined, context.subscriptions);
    return panel;
}
async function getWebviewContent(context, panel) {
    const datavizPath = [context.extensionPath, 'static', 'dataviz'];
    const getWebviewUri = (fileName) => panel.webview.asWebviewUri(vscode.Uri.file(path.join(...datavizPath, fileName)));
    const indexHtml = await vscode.workspace.fs.readFile(vscode.Uri.file(path.join(...datavizPath, 'index.html')));
    // Replace the script paths with the appropriate webview URI.
    const filled = new util_1.TextDecoder('utf-8')
        .decode(indexHtml)
        .replace(/<script data-replace src="([^"]+")/g, match => {
        const fileName = match
            .slice('<script data-replace src="'.length, -1)
            .trim();
        return '<script src="' + getWebviewUri(fileName).toString() + '"';
    });
    return filled;
}
exports.default = feature;
//# sourceMappingURL=dataviz.js.map