"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
// "Here's an updated snippet which will return URIs of workspace files except
// for those ignored either by search.exclude or files.exclude or .gitignore."
// via:
// https://github.com/microsoft/vscode/issues/48674
const vscode_1 = require("vscode");
const child_process_1 = require("child_process");
// import applicationInsights from './telemetry';
const path_1 = require("path");
function findNonIgnoredFiles(pattern, checkGitIgnore = true) {
    return __awaiter(this, void 0, void 0, function* () {
        const exclude = [
            ...Object.keys((yield vscode_1.workspace.getConfiguration('search', null).get('exclude')) || {}),
            ...Object.keys((yield vscode_1.workspace.getConfiguration('files', null).get('exclude')) || {}),
        ].join(',');
        const uris = yield vscode_1.workspace.findFiles(pattern, `{${exclude}}`);
        if (!checkGitIgnore) {
            return uris;
        }
        return filterGitIgnored(uris);
    });
}
exports.default = findNonIgnoredFiles;
// TODO: https://github.com/Microsoft/vscode/blob/release/1.27/extensions/git/src/api/git.d.ts instead of git shell if possible
function filterGitIgnored(uris) {
    return __awaiter(this, void 0, void 0, function* () {
        const workspaceRelativePaths = uris.map((uri) => vscode_1.workspace.asRelativePath(uri, false));
        for (const workspaceDirectory of vscode_1.workspace.workspaceFolders) {
            const workspaceDirectoryPath = workspaceDirectory.uri.fsPath;
            try {
                const { stdout, stderr } = yield new Promise((resolve, reject) => {
                    child_process_1.exec(`git check-ignore ${workspaceRelativePaths.join(' ')}`, { cwd: workspaceDirectoryPath }, 
                    // https://git-scm.com/docs/git-check-ignore#_exit_status
                    (error, stdout, stderr) => {
                        if (error && error.code !== 0 && error.code !== 1) {
                            reject(error);
                            return;
                        }
                        resolve({ stdout, stderr });
                    });
                });
                if (stderr) {
                    throw new Error(stderr);
                }
                for (const relativePath of stdout.split('\n')) {
                    const uri = vscode_1.Uri.file(path_1.join(workspaceDirectoryPath, relativePath.slice(1, -1) /* Remove quotes */));
                    const index = uris.findIndex((u) => u.fsPath === uri.fsPath);
                    if (index > -1) {
                        uris.splice(index, 1);
                    }
                }
            }
            catch (error) {
                console.error('findNonIgnoredFiles-git-exec-error', error);
                //   applicationInsights.sendTelemetryEvent('findNonIgnoredFiles-git-exec-error');
            }
        }
        return uris;
    });
}
//# sourceMappingURL=findNonIgnoredFiles.js.map