"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.JSDebugMessage = void 0;
const __1 = require("..");
const entities_1 = require("../../entities");
class JSDebugMessage extends __1.DebugMessage {
    constructor(lineCodeProcessing) {
        super(lineCodeProcessing);
    }
    content(document, selectedVar, lineOfSelectedVar, wrapLogMessage, logMessagePrefix, quote, addSemicolonInTheEnd, insertEnclosingClass, insertEnclosingFunction, delemiterInsideMessage, includeFileNameAndLineNum, tabSize) {
        const classThatEncloseTheVar = this.enclosingBlockName(document, lineOfSelectedVar, "class");
        const funcThatEncloseTheVar = this.enclosingBlockName(document, lineOfSelectedVar, "function");
        const lineOfLogMsg = this.line(document, lineOfSelectedVar, selectedVar);
        const spacesBeforeMsg = this.spacesBefore(document, lineOfSelectedVar, tabSize);
        const semicolon = addSemicolonInTheEnd ? ";" : "";
        const fileName = document.fileName.includes("/")
            ? document.fileName.split("/")[document.fileName.split("/").length - 1]
            : document.fileName.split("\\")[document.fileName.split("\\").length - 1];
        if (!includeFileNameAndLineNum &&
            !insertEnclosingFunction &&
            !insertEnclosingClass &&
            logMessagePrefix.length === 0) {
            logMessagePrefix = `${delemiterInsideMessage} `;
        }
        const debuggingMsg = `console.log(${quote}${logMessagePrefix}${logMessagePrefix.length !== 0 &&
            logMessagePrefix !== `${delemiterInsideMessage} `
            ? ` ${delemiterInsideMessage} `
            : ""}${includeFileNameAndLineNum
            ? `file: ${fileName} ${delemiterInsideMessage} line ${lineOfLogMsg + 1} ${delemiterInsideMessage} `
            : ""}${insertEnclosingClass
            ? classThatEncloseTheVar.length > 0
                ? `${classThatEncloseTheVar} ${delemiterInsideMessage} `
                : ``
            : ""}${insertEnclosingFunction
            ? funcThatEncloseTheVar.length > 0
                ? `${funcThatEncloseTheVar} ${delemiterInsideMessage} `
                : ""
            : ""}${selectedVar}${quote}, ${selectedVar})${semicolon}`;
        if (wrapLogMessage) {
            // 16 represents the length of console.log("");
            const wrappingMsg = `console.log(${quote}${logMessagePrefix} ${"-".repeat(debuggingMsg.length - 16)}${quote})${semicolon}`;
            return `${lineOfLogMsg === document.lineCount ? "\n" : ""}${spacesBeforeMsg}${wrappingMsg}\n${spacesBeforeMsg}${debuggingMsg}\n${spacesBeforeMsg}${wrappingMsg}\n`;
        }
        return `${lineOfLogMsg === document.lineCount ? "\n" : ""}${spacesBeforeMsg}${debuggingMsg}\n`;
    }
    line(document, selectionLine, selectedVar) {
        if (selectionLine === document.lineCount - 1) {
            return selectionLine;
        }
        const multilineParenthesisVariableLine = this.getMultiLineVariableLine(document, selectionLine, entities_1.LocElement.Parenthesis);
        const multilineBracesVariableLine = this.getMultiLineVariableLine(document, selectionLine, entities_1.LocElement.Braces);
        let currentLineText = document.lineAt(selectionLine).text;
        let nextLineText = document
            .lineAt(selectionLine + 1)
            .text.replace(/\s/g, "");
        if (this.lineCodeProcessing.isObjectLiteralAssignedToVariable(`${currentLineText}\n${nextLineText}`)) {
            return this.objectLiteralLine(document, selectionLine);
        }
        else if (this.lineCodeProcessing.isFunctionAssignedToVariable(`${currentLineText}`)) {
            if (currentLineText.split("=")[0].includes(selectedVar)) {
                return this.functionAssignmentLine(document, selectionLine);
            }
            else {
                return this.functionOpenedBraceLine(document, selectionLine) + 1;
            }
        }
        else if (this.lineCodeProcessing.isObjectFunctionCallAssignedToVariable(`${currentLineText}\n${nextLineText}`) &&
            !this.lineCodeProcessing.isObjectFunctionCallAssignedToVariable(`${nextLineText}`)) {
            return this.objectFunctionCallLine(document, selectionLine, selectedVar);
        }
        else if (this.lineCodeProcessing.isArrayAssignedToVariable(`${currentLineText}\n${currentLineText}`)) {
            return this.arrayLine(document, selectionLine);
        }
        else if (this.lineCodeProcessing.isValueAssignedToVariable(`${currentLineText}\n${currentLineText}`)) {
            return multilineParenthesisVariableLine !== null &&
                this.lineText(document, multilineParenthesisVariableLine - 1).includes("{")
                ? multilineParenthesisVariableLine
                : selectionLine + 1;
        }
        else if (this.lineCodeProcessing.isFunctionDeclaration(currentLineText)) {
            if (multilineParenthesisVariableLine !== null &&
                this.lineText(document, multilineParenthesisVariableLine - 1).includes("{")) {
                return multilineParenthesisVariableLine;
            }
            else {
                const lineOfOpenedBrace = this.functionOpenedBraceLine(document, selectionLine);
                if (lineOfOpenedBrace !== -1) {
                    return lineOfOpenedBrace + 1;
                }
            }
        }
        else if (/`/.test(currentLineText)) {
            return this.templateStringLine(document, selectionLine);
        }
        else if (multilineParenthesisVariableLine !== null &&
            this.lineText(document, multilineParenthesisVariableLine - 1).includes("{")) {
            return multilineParenthesisVariableLine;
        }
        else if (multilineBracesVariableLine !== null) {
            return multilineBracesVariableLine;
        }
        else if (currentLineText.trim().startsWith("return")) {
            return selectionLine;
        }
        return selectionLine + 1;
    }
    objectLiteralLine(document, selectionLine) {
        let currentLineText = document.lineAt(selectionLine).text;
        let nbrOfOpenedBrackets = (currentLineText.match(/{/g) || [])
            .length;
        let nbrOfClosedBrackets = (currentLineText.match(/}/g) || [])
            .length;
        let currentLineNum = selectionLine + 1;
        while (currentLineNum < document.lineCount) {
            const currentLineText = document.lineAt(currentLineNum).text;
            nbrOfOpenedBrackets += (currentLineText.match(/{/g) || []).length;
            nbrOfClosedBrackets += (currentLineText.match(/}/g) || []).length;
            currentLineNum++;
            if (nbrOfOpenedBrackets === nbrOfClosedBrackets) {
                break;
            }
        }
        return nbrOfClosedBrackets === nbrOfOpenedBrackets
            ? currentLineNum
            : selectionLine + 1;
    }
    objectFunctionCallLine(document, selectionLine, selectedVar) {
        let currentLineText = document.lineAt(selectionLine).text;
        let nextLineText = document
            .lineAt(selectionLine + 1)
            .text.replace(/\s/g, "");
        if (/\((\s*)$/.test(currentLineText.split(selectedVar)[0]) ||
            /,(\s*)$/.test(currentLineText.split(selectedVar)[0])) {
            return selectionLine + 1;
        }
        let totalOpenedParenthesis = 0;
        let totalClosedParenthesis = 0;
        const { openedElementOccurrences, closedElementOccurrences, } = this.locOpenedClosedElementOccurrences(currentLineText, entities_1.LocElement.Parenthesis);
        totalOpenedParenthesis += openedElementOccurrences;
        totalClosedParenthesis += closedElementOccurrences;
        let currentLineNum = selectionLine + 1;
        if (totalOpenedParenthesis !== totalClosedParenthesis ||
            currentLineText.endsWith(".") ||
            nextLineText.trim().startsWith(".")) {
            while (currentLineNum < document.lineCount) {
                currentLineText = document.lineAt(currentLineNum).text;
                const { openedElementOccurrences, closedElementOccurrences, } = this.locOpenedClosedElementOccurrences(currentLineText, entities_1.LocElement.Parenthesis);
                totalOpenedParenthesis += openedElementOccurrences;
                totalClosedParenthesis += closedElementOccurrences;
                if (currentLineNum === document.lineCount - 1) {
                    break;
                }
                nextLineText = document.lineAt(currentLineNum + 1).text;
                currentLineNum++;
                if (totalOpenedParenthesis === totalClosedParenthesis &&
                    !currentLineText.endsWith(".") &&
                    !nextLineText.trim().startsWith(".")) {
                    break;
                }
            }
        }
        return totalOpenedParenthesis === totalClosedParenthesis
            ? currentLineNum
            : selectionLine + 1;
    }
    functionAssignmentLine(document, selectionLine) {
        const currentLineText = document.lineAt(selectionLine).text;
        if (/{/.test(currentLineText)) {
            return (this.closingElementLine(document, selectionLine, entities_1.LocElement.Braces) + 1);
        }
        else {
            const closedParenthesisLine = this.closingElementLine(document, selectionLine, entities_1.LocElement.Parenthesis);
            return (this.closingElementLine(document, closedParenthesisLine, entities_1.LocElement.Braces) + 1);
        }
    }
    templateStringLine(document, selectionLine) {
        let currentLineText = document.lineAt(selectionLine).text;
        let currentLineNum = selectionLine + 1;
        let nbrOfBackticks = (currentLineText.match(/`/g) || []).length;
        while (currentLineNum < document.lineCount) {
            const currentLineText = document.lineAt(currentLineNum).text;
            nbrOfBackticks += (currentLineText.match(/`/g) || []).length;
            if (nbrOfBackticks % 2 === 0) {
                break;
            }
            currentLineNum++;
        }
        return nbrOfBackticks % 2 === 0 ? currentLineNum + 1 : selectionLine + 1;
    }
    arrayLine(document, selectionLine) {
        let currentLineText = document.lineAt(selectionLine).text;
        let nbrOfOpenedBrackets = (currentLineText.match(/\[/g) || [])
            .length;
        let nbrOfClosedBrackets = (currentLineText.match(/\]/g) || [])
            .length;
        let currentLineNum = selectionLine + 1;
        if (nbrOfOpenedBrackets !== nbrOfClosedBrackets) {
            while (currentLineNum < document.lineCount) {
                const currentLineText = document.lineAt(currentLineNum).text;
                nbrOfOpenedBrackets += (currentLineText.match(/\[/g) || []).length;
                nbrOfClosedBrackets += (currentLineText.match(/\]/g) || []).length;
                currentLineNum++;
                if (nbrOfOpenedBrackets === nbrOfClosedBrackets) {
                    break;
                }
            }
        }
        return nbrOfOpenedBrackets === nbrOfClosedBrackets
            ? currentLineNum
            : selectionLine + 1;
    }
    // Line for a variable which is in multiline context (function paramter, or deconstructred object)
    getMultiLineVariableLine(document, lineNum, blockType) {
        let currentLineNum = lineNum - 1;
        let nbrOfOpenedBlockType = 0;
        let nbrOfClosedBlockType = 1; // Closing parenthesis
        while (currentLineNum >= 0) {
            const currentLineText = document.lineAt(currentLineNum).text;
            const currentLineParenthesis = this.locOpenedClosedElementOccurrences(currentLineText, blockType);
            nbrOfOpenedBlockType += currentLineParenthesis.openedElementOccurrences;
            nbrOfClosedBlockType += currentLineParenthesis.closedElementOccurrences;
            if (nbrOfOpenedBlockType === nbrOfClosedBlockType) {
                return this.closingElementLine(document, currentLineNum, blockType) + 1;
            }
            currentLineNum--;
        }
        return null;
    }
    functionOpenedBraceLine(docuemt, line) {
        let nbrOfOpenedBraces = 0;
        let nbrOfClosedBraces = 0;
        while (line < docuemt.lineCount) {
            const { openedElementOccurrences, closedElementOccurrences, } = this.locOpenedClosedElementOccurrences(this.lineText(docuemt, line), entities_1.LocElement.Braces);
            nbrOfOpenedBraces += openedElementOccurrences;
            nbrOfClosedBraces += closedElementOccurrences;
            if (nbrOfOpenedBraces - nbrOfClosedBraces === 1) {
                return line;
            }
            line++;
        }
        return -1;
    }
    spacesBefore(document, line, tabSize) {
        const currentLine = document.lineAt(line);
        const currentLineTextChars = currentLine.text.split("");
        if ((!this.lineCodeProcessing.isFunctionAssignedToVariable(currentLine.text) &&
            this.lineCodeProcessing.doesContainsNamedFunctionDeclaration(currentLine.text)) ||
            this.lineCodeProcessing.doesContainsBuiltInFunction(currentLine.text) ||
            this.lineCodeProcessing.doesContainClassDeclaration(currentLine.text)) {
            const nextLine = document.lineAt(line + 1);
            const nextLineTextChars = nextLine.text.split("");
            if (nextLineTextChars.filter((char) => char !== " ").length !== 0) {
                if (nextLine.firstNonWhitespaceCharacterIndex >
                    currentLine.firstNonWhitespaceCharacterIndex) {
                    if (nextLineTextChars[nextLine.firstNonWhitespaceCharacterIndex - 1] ===
                        "\t") {
                        return " ".repeat(nextLine.firstNonWhitespaceCharacterIndex * tabSize);
                    }
                    else {
                        return " ".repeat(nextLine.firstNonWhitespaceCharacterIndex);
                    }
                }
                else {
                    if (currentLineTextChars[currentLine.firstNonWhitespaceCharacterIndex - 1] === "\t") {
                        return " ".repeat(currentLine.firstNonWhitespaceCharacterIndex * tabSize);
                    }
                    else {
                        return " ".repeat(currentLine.firstNonWhitespaceCharacterIndex);
                    }
                }
            }
            else {
                if (currentLineTextChars[currentLine.firstNonWhitespaceCharacterIndex - 1] === "\t") {
                    return " ".repeat(currentLine.firstNonWhitespaceCharacterIndex * tabSize);
                }
                else {
                    return " ".repeat(currentLine.firstNonWhitespaceCharacterIndex);
                }
            }
        }
        else {
            if (currentLineTextChars[currentLine.firstNonWhitespaceCharacterIndex - 1] === "\t") {
                return " ".repeat(currentLine.firstNonWhitespaceCharacterIndex * tabSize);
            }
            else {
                return " ".repeat(currentLine.firstNonWhitespaceCharacterIndex);
            }
        }
    }
    enclosingBlockName(document, lineOfSelectedVar, blockType) {
        let currentLineNum = lineOfSelectedVar;
        while (currentLineNum >= 0) {
            const currentLineText = document.lineAt(currentLineNum).text;
            switch (blockType) {
                case "class":
                    if (this.lineCodeProcessing.doesContainClassDeclaration(currentLineText)) {
                        if (lineOfSelectedVar > currentLineNum &&
                            lineOfSelectedVar <
                                this.closingElementLine(document, currentLineNum, entities_1.LocElement.Braces)) {
                            return `${this.lineCodeProcessing.getClassName(currentLineText)}`;
                        }
                    }
                    break;
                case "function":
                    if (this.lineCodeProcessing.doesContainsNamedFunctionDeclaration(currentLineText) &&
                        !this.lineCodeProcessing.doesContainsBuiltInFunction(currentLineText)) {
                        if (lineOfSelectedVar >= currentLineNum &&
                            lineOfSelectedVar <
                                this.closingElementLine(document, currentLineNum, entities_1.LocElement.Braces)) {
                            if (this.lineCodeProcessing.getFunctionName(currentLineText)
                                .length !== 0) {
                                return `${this.lineCodeProcessing.getFunctionName(currentLineText)}`;
                            }
                            return "";
                        }
                    }
                    break;
            }
            currentLineNum--;
        }
        return "";
    }
    detectAll(document, tabSize, delemiterInsideMessage, quote) {
        const documentNbrOfLines = document.lineCount;
        const logMessages = [];
        for (let i = 0; i < documentNbrOfLines; i++) {
            const turboConsoleLogMessage = /console\.log\(/;
            if (turboConsoleLogMessage.test(document.lineAt(i).text)) {
                const logMessage = {
                    spaces: "",
                    lines: [],
                };
                logMessage.spaces = this.spacesBefore(document, i, tabSize);
                const closedParenthesisLine = this.closingElementLine(document, i, entities_1.LocElement.Parenthesis);
                let msg = "";
                for (let j = i; j <= closedParenthesisLine; j++) {
                    msg += document.lineAt(j).text;
                    logMessage.lines.push(document.lineAt(j).rangeIncludingLineBreak);
                }
                if (new RegExp(`${delemiterInsideMessage}[a-zA-Z0-9]+${quote},(//)?[a-zA-Z0-9]+`).test(msg.replace(/\s/g, ""))) {
                    logMessages.push(logMessage);
                }
            }
        }
        return logMessages;
    }
}
exports.JSDebugMessage = JSDebugMessage;
//# sourceMappingURL=index.js.map