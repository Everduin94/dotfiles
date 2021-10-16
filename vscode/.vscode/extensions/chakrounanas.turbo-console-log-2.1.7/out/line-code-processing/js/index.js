"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.JSLineCodeProcessing = void 0;
class JSLineCodeProcessing {
    isValueAssignedToVariable(loc) {
        return /.*=.*/.test(loc) && !/=>/.test(loc);
    }
    isObjectLiteralAssignedToVariable(loc) {
        const locWithoutWhiteSpaces = loc.replace(/\s/g, "");
        return /(const|let|var)[a-zA-Z0-9]*.*={.+:.+/.test(locWithoutWhiteSpaces);
    }
    isArrayAssignedToVariable(loc) {
        const locWithoutWhiteSpaces = loc.replace(/\s/g, "");
        return /(const|let|var).*=\[.*/.test(locWithoutWhiteSpaces);
    }
    doesContainClassDeclaration(loc) {
        return /class(\s+).*{/.test(loc);
    }
    getClassName(loc) {
        if (this.doesContainClassDeclaration(loc)) {
            return loc.split("class ")[1].trim().split(" ")[0].replace("{", "");
        }
        else {
            return "";
        }
    }
    doesContainsBuiltInFunction(loc) {
        const locWithoutWhiteSpaces = loc.replace(/\s/g, "");
        return /(if|switch|while|for|catch|do)\(.*\)/.test(locWithoutWhiteSpaces);
    }
    doesContainsNamedFunctionDeclaration(loc) {
        const locWithoutFunctionKeyword = loc.replace("function", "");
        const regularNamedFunctionRegex = new RegExp(/\s*[a-zA-Z0-9]+\s*\(.*\):?.*{/);
        const regularFunctionAssignedToVariableRegex = new RegExp(/(const|let|var)(\s*)[a-zA-Z0-9]*\s*=(\s*)\(.*\)(\s*){/);
        const arrowFunctionAssignedToVariableRegex = new RegExp(/(const|let|var)(\s*)[a-zA-Z0-9]*\s*=(\s*)\(.*\):?\s*[a-zA-Z0-9]*(\s*)=>(\s*){/);
        return (regularNamedFunctionRegex.test(locWithoutFunctionKeyword) ||
            regularFunctionAssignedToVariableRegex.test(locWithoutFunctionKeyword) ||
            arrowFunctionAssignedToVariableRegex.test(loc));
    }
    isFunctionAssignedToVariable(loc) {
        return /(const|let|var)(\s*)[a-zA-Z0-9]*\s*=.*\(.*/.test(loc);
    }
    isFunctionDeclaration(loc) {
        const locWithoutWhiteSpaces = loc.replace(/\s/g, "");
        return (/.*\(.*/.test(locWithoutWhiteSpaces) || /=>/.test(locWithoutWhiteSpaces));
    }
    isObjectFunctionCall(loc) {
        const locWithoutWhiteSpaces = loc.replace(/\s/g, "");
        return /([a-zA-Z0-9]+\.){1,}/.test(locWithoutWhiteSpaces);
    }
    getFunctionName(loc) {
        if (this.doesContainsNamedFunctionDeclaration(loc)) {
            if (/(const|let|var)(\s*)[a-zA-Z0-9]*\s*=/.test(loc)) {
                return loc
                    .split("=")[0]
                    .replace(/export |module.exports |const |var |let |=|(\s*)/g, "");
            }
            else if (/function(\s+)/.test(loc)) {
                return loc.split("function ")[1].split("(")[0].replace(/(\s*)/g, "");
            }
            else {
                return loc
                    .split(/\(.*\)/)[0]
                    .replace(/async |static |public |private |protected |export |default |(\s*)/g, "");
            }
        }
        else {
            return "";
        }
    }
}
exports.JSLineCodeProcessing = JSLineCodeProcessing;
//# sourceMappingURL=index.js.map