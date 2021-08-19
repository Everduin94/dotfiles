"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DebugMessage = void 0;
const entities_1 = require("../entities");
class DebugMessage {
    constructor(lineCodeProcessing) {
        this.lineCodeProcessing = lineCodeProcessing;
    }
    closingElementLine(document, lineNum, locElement) {
        const docNbrOfLines = document.lineCount;
        let closingElementFound = false;
        let openedElementOccurrences = 0;
        let closedElementOccurrences = 0;
        while (!closingElementFound && lineNum < docNbrOfLines - 1) {
            const currentLineText = document.lineAt(lineNum).text;
            const openedClosedElementOccurrences = this.locOpenedClosedElementOccurrences(currentLineText, locElement);
            openedElementOccurrences +=
                openedClosedElementOccurrences.openedElementOccurrences;
            closedElementOccurrences +=
                openedClosedElementOccurrences.closedElementOccurrences;
            if (openedElementOccurrences === closedElementOccurrences) {
                closingElementFound = true;
                return lineNum;
            }
            lineNum++;
        }
        return lineNum;
    }
    locOpenedClosedElementOccurrences(loc, locElement) {
        let openedElementOccurrences = 0;
        let closedElementOccurrences = 0;
        const openedElement = locElement === entities_1.LocElement.Parenthesis ? /\(/g : /{/g;
        const closedElement = locElement === entities_1.LocElement.Parenthesis ? /\)/g : /}/g;
        while (openedElement.exec(loc)) {
            openedElementOccurrences++;
        }
        while (closedElement.exec(loc)) {
            closedElementOccurrences++;
        }
        return {
            openedElementOccurrences,
            closedElementOccurrences,
        };
    }
    lineText(document, line) {
        return document.lineAt(line).text;
    }
}
exports.DebugMessage = DebugMessage;
//# sourceMappingURL=index.js.map