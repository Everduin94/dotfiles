"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = void 0;
const vscode_1 = require("vscode");
const foam_core_1 = require("foam-core");
const features_1 = require("./features");
const config_1 = require("./services/config");
const logging_1 = require("./services/logging");
function createMarkdownProvider(config) {
    const matcher = new foam_core_1.Matcher(config.workspaceFolders, config.includeGlobs, config.ignoreGlobs);
    const provider = new foam_core_1.MarkdownResourceProvider(matcher, triggers => {
        const watcher = vscode_1.workspace.createFileSystemWatcher('**/*');
        return [
            watcher.onDidChange(triggers.onDidChange),
            watcher.onDidCreate(triggers.onDidCreate),
            watcher.onDidDelete(triggers.onDidDelete),
            watcher,
        ];
    });
    return provider;
}
async function activate(context) {
    const logger = new logging_1.VsCodeOutputLogger();
    foam_core_1.Logger.setDefaultLogger(logger);
    logging_1.exposeLogger(context, logger);
    try {
        foam_core_1.Logger.info('Starting Foam');
        // Prepare Foam
        const config = config_1.getConfigFromVscode();
        const dataStore = new foam_core_1.FileDataStore();
        const markdownProvider = createMarkdownProvider(config);
        const foamPromise = foam_core_1.bootstrap(config, dataStore, [markdownProvider]);
        // Load the features
        const resPromises = features_1.features.map(f => f.activate(context, foamPromise));
        const foam = await foamPromise;
        foam_core_1.Logger.info(`Loaded ${foam.workspace.list().length} notes`);
        context.subscriptions.push(foam, markdownProvider);
        const res = (await Promise.all(resPromises)).filter(r => r != null);
        return {
            extendMarkdownIt: (md) => {
                return res.reduce((acc, r) => {
                    return r.extendMarkdownIt ? r.extendMarkdownIt(acc) : acc;
                }, md);
            },
        };
    }
    catch (e) {
        foam_core_1.Logger.error('An error occurred while bootstrapping Foam', e);
        vscode_1.window.showErrorMessage(`An error occurred while bootstrapping Foam. ${e.stack}`);
    }
}
exports.activate = activate;
//# sourceMappingURL=extension.js.map