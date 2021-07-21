"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MarkdownReferenceProvider = void 0;
const NoteParser_1 = require("./NoteParser");
const Ref_1 = require("./Ref");
class MarkdownReferenceProvider {
    provideReferences(document, position, context, token) {
        // console.debug('MarkdownReferenceProvider.provideReferences');
        const ref = Ref_1.getRefAt(document, position);
        // debugRef(ref);
        return NoteParser_1.NoteParser.search(ref);
    }
}
exports.MarkdownReferenceProvider = MarkdownReferenceProvider;
//# sourceMappingURL=MarkdownReferenceProvider.js.map