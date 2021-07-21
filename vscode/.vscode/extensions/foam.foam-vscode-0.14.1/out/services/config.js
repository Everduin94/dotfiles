"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.monitorFoamVsCodeConfig = exports.updateFoamVsCodeConfig = exports.getFoamVsCodeConfig = exports.getConfigFromVscode = void 0;
const vscode_1 = require("vscode");
const foam_core_1 = require("foam-core");
const settings_1 = require("../settings");
// TODO this is still to be improved - foam config should
// not be dependent on vscode but at the moment it's convenient
// to leverage it
exports.getConfigFromVscode = () => {
    const workspaceFolders = vscode_1.workspace.workspaceFolders.map(dir => dir.uri);
    const excludeGlobs = settings_1.getIgnoredFilesSetting();
    return foam_core_1.createConfigFromFolders(workspaceFolders, {
        ignore: excludeGlobs.map(g => g.toString()),
    });
};
exports.getFoamVsCodeConfig = (key) => vscode_1.workspace.getConfiguration('foam').get(key);
exports.updateFoamVsCodeConfig = (key, value) => vscode_1.workspace.getConfiguration().update('foam.' + key, value);
exports.monitorFoamVsCodeConfig = (key) => {
    let value = exports.getFoamVsCodeConfig(key);
    const listener = vscode_1.workspace.onDidChangeConfiguration(e => {
        if (e.affectsConfiguration('foam.' + key)) {
            value = exports.getFoamVsCodeConfig(key);
        }
    });
    const ret = () => {
        return value;
    };
    ret.dispose = () => listener.dispose();
    return ret;
};
//# sourceMappingURL=config.js.map