"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function fileIs(path, ...items) {
    if (items) {
        for (var index = 0; index < items.length; index++) {
            if (path.endsWith(items[index].toLowerCase())) {
                return true;
            }
        }
    }
    return false;
}
exports.fileIs = fileIs;
function getFileNameWithoutExtension(path) {
    let parts = path.split(".");
    parts.pop();
    if (parts.length > 1) {
        if (parts[parts.length - 1] === "spec") {
            parts.pop();
        }
        if (parts[parts.length - 1] === "ng") {
            parts.pop();
        }
    }
    return parts.join(".");
}
exports.getFileNameWithoutExtension = getFileNameWithoutExtension;
//# sourceMappingURL=common.js.map