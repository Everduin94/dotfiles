"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.removeFoamMetadata = exports.extractFoamTemplateFrontmatterMetadata = void 0;
const gray_matter_1 = __importDefault(require("gray-matter"));
function extractFoamTemplateFrontmatterMetadata(contents) {
    // Need to pass in empty options object, in order to bust a cache
    // See https://github.com/jonschlinkert/gray-matter/issues/124
    const parsed = gray_matter_1.default(contents, {});
    let metadata = new Map();
    if (parsed.language !== 'yaml') {
        // We might allow this in the future, once it has been tested adequately.
        // But for now we'll be safe and prevent people from using anything else.
        return [metadata, contents];
    }
    const frontmatter = parsed.data;
    const frontmatterKeys = Object.keys(frontmatter);
    const foamMetadata = frontmatter['foam_template'];
    if (typeof foamMetadata !== 'object') {
        return [metadata, contents];
    }
    const containsFoam = foamMetadata !== undefined;
    const onlyFoam = containsFoam && frontmatterKeys.length === 1;
    metadata = new Map(Object.entries(foamMetadata || {}));
    let newContents = contents;
    if (containsFoam) {
        if (onlyFoam) {
            // We'll remove the entire frontmatter block
            newContents = parsed.content;
            // If there is another frontmatter block, we need to remove
            // the leading space left behind.
            const anotherFrontmatter = gray_matter_1.default(newContents.trimStart()).matter !== '';
            if (anotherFrontmatter) {
                newContents = newContents.trimStart();
            }
        }
        else {
            // We'll remove only the Foam bits
            newContents = removeFoamMetadata(contents);
        }
    }
    return [metadata, newContents];
}
exports.extractFoamTemplateFrontmatterMetadata = extractFoamTemplateFrontmatterMetadata;
function removeFoamMetadata(contents) {
    return contents.replace(/^\s*foam_template:.*?\n(?:\s*(?:filepath|name|description):.*\n)+/gm, '');
}
exports.removeFoamMetadata = removeFoamMetadata;
//# sourceMappingURL=template-frontmatter-parser.js.map