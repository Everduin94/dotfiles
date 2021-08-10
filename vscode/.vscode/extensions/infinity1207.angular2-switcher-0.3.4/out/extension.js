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
const vscode = require("vscode");
const common_1 = require("./common");
const template_definition_provider_1 = require("./template-definition-provider");
let previous = "";
let openSideBySide = vscode.workspace.getConfiguration("angular2-switcher").get("openSideBySide");
let styleFormats = vscode.workspace.getConfiguration("angular2-switcher").get("styleFormats");
let templateFormats = vscode.workspace.getConfiguration("angular2-switcher").get("templateFormats");
function activate(context) {
    let switchTemplateCommand = vscode.commands.registerCommand('extension.switchTemplate', switchTemplate);
    context.subscriptions.push(switchTemplateCommand);
    let switchTsCommand = vscode.commands.registerCommand('extension.switchTs', switchTs);
    context.subscriptions.push(switchTsCommand);
    let switchStyleCommand = vscode.commands.registerCommand('extension.switchStyle', switchStyle);
    context.subscriptions.push(switchStyleCommand);
    let switchSpecCommand = vscode.commands.registerCommand('extension.switchSpec', switchSpec);
    context.subscriptions.push(switchSpecCommand);
    templateFormats.forEach((f) => {
        if (f.startsWith('.')) {
            f = f.slice(1);
        }
        let filter = { language: f, scheme: "file" };
        context.subscriptions.push(vscode.languages.registerDefinitionProvider(filter, new template_definition_provider_1.TemplateDefinitionProvider()));
    });
}
exports.activate = activate;
function deactivate() { }
exports.deactivate = deactivate;
function switchTemplate() {
    return __awaiter(this, void 0, void 0, function* () {
        let editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        let currentFile = editor.document.fileName;
        let fileNameWithoutExtension = common_1.getFileNameWithoutExtension(currentFile);
        if (fileIsTs(currentFile) || fileIsStyle(currentFile) || fileIsSpec(currentFile)) {
            openCorrespondingFile(fileNameWithoutExtension, ...templateFormats);
        }
        else if (fileIsTemplate(currentFile)) {
            if (previous && previous !== currentFile) {
                if (previous.startsWith(fileNameWithoutExtension)) {
                    openFile(previous);
                }
                else {
                    openCorrespondingFile(fileNameWithoutExtension, ".ts");
                }
            }
            else {
                openCorrespondingFile(fileNameWithoutExtension, ".ts");
            }
        }
    });
}
function switchTs() {
    return __awaiter(this, void 0, void 0, function* () {
        let editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        let currentFile = editor.document.fileName;
        let fileNameWithoutExtension = common_1.getFileNameWithoutExtension(currentFile);
        if (fileIsStyle(currentFile) || fileIsTemplate(currentFile) || fileIsSpec(currentFile)) {
            openCorrespondingFile(fileNameWithoutExtension, ".ts");
        }
        else if (fileIsTs(currentFile)) {
            if (previous && previous !== currentFile) {
                if (previous.startsWith(fileNameWithoutExtension)) {
                    openFile(previous);
                }
                else {
                    openCorrespondingFile(fileNameWithoutExtension, ...templateFormats);
                }
            }
            else {
                openCorrespondingFile(fileNameWithoutExtension, ...templateFormats);
            }
        }
    });
}
function switchStyle() {
    return __awaiter(this, void 0, void 0, function* () {
        let editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        let currentFile = editor.document.fileName;
        let fileNameWithoutExtension = common_1.getFileNameWithoutExtension(currentFile);
        if (fileIsTs(currentFile) || fileIsTemplate(currentFile) || fileIsSpec(currentFile)) {
            openCorrespondingFile(fileNameWithoutExtension, ...styleFormats);
        }
        else if (fileIsStyle(currentFile)) {
            if (previous && previous !== currentFile) {
                if (previous.startsWith(fileNameWithoutExtension)) {
                    openFile(previous);
                }
                else {
                    openCorrespondingFile(fileNameWithoutExtension, ...templateFormats);
                }
            }
            else {
                openCorrespondingFile(fileNameWithoutExtension, ...templateFormats);
            }
        }
    });
}
function switchSpec() {
    return __awaiter(this, void 0, void 0, function* () {
        let editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        let currentFile = editor.document.fileName;
        let fileNameWithoutExtension = common_1.getFileNameWithoutExtension(currentFile);
        if (fileIsTs(currentFile) || fileIsStyle(currentFile) || fileIsTemplate(currentFile)) {
            openCorrespondingFile(fileNameWithoutExtension, ".spec.ts");
        }
        else if (fileIsSpec(currentFile)) {
            if (previous && previous !== currentFile) {
                if (previous.startsWith(fileNameWithoutExtension)) {
                    openFile(previous);
                }
                else {
                    openCorrespondingFile(fileNameWithoutExtension, ".ts");
                }
            }
            else {
                openCorrespondingFile(fileNameWithoutExtension, ".ts");
            }
        }
    });
}
function openFile(fileName) {
    return __awaiter(this, void 0, void 0, function* () {
        var editor = vscode.window.activeTextEditor;
        if (!editor) {
            return false;
        }
        try {
            let doc = yield vscode.workspace.openTextDocument(fileName);
            if (doc) {
                yield vscode.window.showTextDocument(doc, openSideBySide ? vscode.ViewColumn.Two : editor.viewColumn);
            }
            previous = editor.document.fileName;
            return true;
        }
        catch (error) {
            return false;
        }
    });
}
function openCorrespondingFile(fileNameWithoutExtension, ...formats) {
    return __awaiter(this, void 0, void 0, function* () {
        var editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        for (let index = 0; index < formats.length; index++) {
            const fileName = `${fileNameWithoutExtension}${formats[index]}`;
            var succ = yield openFile(fileName);
            if (succ) {
                break;
            }
        }
    });
}
function fileIsTemplate(path) {
    return common_1.fileIs(path, ...templateFormats);
}
function fileIsStyle(path) {
    return common_1.fileIs(path, ...styleFormats);
}
function fileIsTs(path) {
    if (fileIsSpec(path)) {
        return false;
    }
    return common_1.fileIs(path, ".ts");
}
function fileIsSpec(path) {
    return common_1.fileIs(path, ".spec.ts");
}
//# sourceMappingURL=extension.js.map