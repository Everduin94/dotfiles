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
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
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
exports.deactivate = exports.activate = void 0;
const vscode = __importStar(require("vscode"));
const js_1 = require("./debug-message/js");
const js_2 = require("./line-code-processing/js");
function activate(context) {
    const jsLineCodeProcessing = new js_2.JSLineCodeProcessing();
    const jsDebugMessage = new js_1.JSDebugMessage(jsLineCodeProcessing);
    // Insert debug message
    vscode.commands.registerCommand("turboConsoleLog.displayLogMessage", () => __awaiter(this, void 0, void 0, function* () {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        const tabSize = getTabSize(editor.options.tabSize);
        const document = editor.document;
        const config = vscode.workspace.getConfiguration("turboConsoleLog");
        const properties = getExtensionProperties(config);
        for (let index = 0; index < editor.selections.length; index++) {
            const selection = editor.selections[index];
            const selectedVar = document.getText(selection);
            const lineOfSelectedVar = selection.active.line;
            // Check if the selection line is not the last one in the document and the selected variable is not empty
            if (selectedVar.trim().length !== 0) {
                yield editor.edit((editBuilder) => {
                    const logMessageLine = jsDebugMessage.line(document, lineOfSelectedVar, selectedVar);
                    editBuilder.insert(new vscode.Position(logMessageLine >= document.lineCount
                        ? document.lineCount
                        : logMessageLine, 0), jsDebugMessage.content(document, selectedVar, lineOfSelectedVar, properties.wrapLogMessage, properties.logMessagePrefix, properties.quote, properties.addSemicolonInTheEnd, properties.insertEnclosingClass, properties.insertEnclosingFunction, properties.delimiterInsideMessage, properties.includeFileNameAndLineNum, tabSize));
                });
            }
        }
    }));
    // Comment all debug messages
    vscode.commands.registerCommand("turboConsoleLog.commentAllLogMessages", () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        const tabSize = getTabSize(editor.options.tabSize);
        const document = editor.document;
        const config = vscode.workspace.getConfiguration("turboConsoleLog");
        const properties = getExtensionProperties(config);
        const logMessages = jsDebugMessage.detectAll(document, tabSize, properties.delimiterInsideMessage, properties.quote);
        editor.edit((editBuilder) => {
            logMessages.forEach(({ spaces, lines }) => {
                lines.forEach((line) => {
                    editBuilder.delete(line);
                    editBuilder.insert(new vscode.Position(line.start.line, 0), `${spaces}// ${document.getText(line).trim()}\n`);
                });
            });
        });
    });
    // Uncomment all debug messages
    vscode.commands.registerCommand("turboConsoleLog.uncommentAllLogMessages", () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        const tabSize = getTabSize(editor.options.tabSize);
        const document = editor.document;
        const config = vscode.workspace.getConfiguration("turboConsoleLog");
        const properties = getExtensionProperties(config);
        const logMessages = jsDebugMessage.detectAll(document, tabSize, properties.delimiterInsideMessage, properties.quote);
        editor.edit((editBuilder) => {
            logMessages.forEach(({ spaces, lines }) => {
                lines.forEach((line) => {
                    editBuilder.delete(line);
                    editBuilder.insert(new vscode.Position(line.start.line, 0), `${spaces}${document.getText(line).replace(/\//g, "").trim()}\n`);
                });
            });
        });
    });
    // Delete all debug messages
    vscode.commands.registerCommand("turboConsoleLog.deleteAllLogMessages", () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        const tabSize = getTabSize(editor.options.tabSize);
        const document = editor.document;
        const config = vscode.workspace.getConfiguration("turboConsoleLog");
        const properties = getExtensionProperties(config);
        const logMessages = jsDebugMessage.detectAll(document, tabSize, properties.delimiterInsideMessage, properties.quote);
        editor.edit((editBuilder) => {
            logMessages.forEach(({ lines }) => {
                lines.forEach((line) => {
                    editBuilder.delete(line);
                });
            });
        });
    });
}
exports.activate = activate;
function deactivate() { }
exports.deactivate = deactivate;
function getExtensionProperties(workspaceConfig) {
    const wrapLogMessage = workspaceConfig.wrapLogMessage || false;
    const logMessagePrefix = workspaceConfig.logMessagePrefix
        ? workspaceConfig.logMessagePrefix
        : "";
    const addSemicolonInTheEnd = workspaceConfig.addSemicolonInTheEnd || false;
    const insertEnclosingClass = workspaceConfig.insertEnclosingClass;
    const insertEnclosingFunction = workspaceConfig.insertEnclosingFunction;
    const quote = workspaceConfig.quote || '"';
    const delimiterInsideMessage = workspaceConfig.delimiterInsideMessage || "~";
    const includeFileNameAndLineNum = workspaceConfig.includeFileNameAndLineNum || false;
    const extensionProperties = {
        wrapLogMessage,
        logMessagePrefix,
        addSemicolonInTheEnd,
        insertEnclosingClass,
        insertEnclosingFunction,
        quote,
        delimiterInsideMessage,
        includeFileNameAndLineNum,
    };
    return extensionProperties;
}
function getTabSize(tabSize) {
    if (tabSize && typeof tabSize === "number") {
        return tabSize;
    }
    else if (tabSize && typeof tabSize === "string") {
        return parseInt(tabSize);
    }
    else {
        return 4;
    }
}
//# sourceMappingURL=extension.js.map