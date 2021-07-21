"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refFromWikiLinkText = exports.refHasExtension = exports.getRefOrEmptyRefAt = exports.getEmptyRefAt = exports.getRefAt = exports.NULL_REF = exports.debugRef = exports.RefType = void 0;
/*
A `Ref` is a match for:

- a [[wiki-link]]
- a #tag
- a @bibtex-citations

in the content of a Note document in your workspace.

*/
const vscode = require("vscode");
const BibTeXCitations_1 = require("./BibTeXCitations");
const NoteWorkspace_1 = require("./NoteWorkspace");
var RefType;
(function (RefType) {
    RefType[RefType["Null"] = 0] = "Null";
    RefType[RefType["WikiLink"] = 1] = "WikiLink";
    RefType[RefType["Tag"] = 2] = "Tag";
    RefType[RefType["Hyperlink"] = 3] = "Hyperlink";
    RefType[RefType["BibTeX"] = 4] = "BibTeX";
})(RefType = exports.RefType || (exports.RefType = {}));
exports.debugRef = (ref) => {
    const { type, word, hasExtension, range } = ref;
    console.debug({
        type: RefType[ref.type],
        word: ref.word,
        hasExtension: ref.hasExtension,
        range: ref.range,
    });
};
exports.NULL_REF = {
    type: RefType.Null,
    word: '',
    hasExtension: null,
    range: undefined,
};
/*
NB: only returns for non-empty refs, eg,
  [[l]] #t or @b
but not
  [[ [[]] # b@ or @
*/
function getRefAt(document, position) {
    let ref;
    let regex;
    let range;
    // let rp = new RemarkParser(document.getText());
    // rp.walkWikiLinksAndTags();
    // let currentNode = rp.getNodeAtPosition(position);
    // #tag regexp
    regex = NoteWorkspace_1.NoteWorkspace.rxTag();
    range = document.getWordRangeAtPosition(position, regex);
    if (range) {
        // here we do nothing to modify the range because the replacements
        // will include the # character, so we want to keep the leading #
        ref = document.getText(range);
        if (ref) {
            return {
                type: RefType.Tag,
                word: ref.replace(/^\#+/, ''),
                hasExtension: null,
                range: range,
            };
        }
    }
    regex = NoteWorkspace_1.NoteWorkspace.rxWikiLink();
    range = document.getWordRangeAtPosition(position, regex);
    if (range) {
        // Our rxWikiLink contains [[ and ]] chars
        // but the replacement words do NOT.
        // So, account for the (exactly) 2 [[  chars at beginning of the match
        // since our replacement words do not contain [[ chars
        let s = new vscode.Position(range.start.line, range.start.character + 2);
        // And, account for the (exactly) 2 ]]  chars at beginning of the match
        // since our replacement words do not contain ]] chars
        let e = new vscode.Position(range.end.line, range.end.character - 2);
        // keep the end
        let r = new vscode.Range(s, e);
        ref = document.getText(r);
        if (ref) {
            // Check for piped wiki-links
            ref = NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink(ref);
            return {
                type: RefType.WikiLink,
                word: ref,
                hasExtension: exports.refHasExtension(ref),
                range: r,
            };
        }
    }
    regex = NoteWorkspace_1.NoteWorkspace.rxMarkdownHyperlink();
    range = document.getWordRangeAtPosition(position, regex);
    if (range) {
        ref = document.getText(range);
        // remove the [description] from the hyperlink
        ref = ref.replace(/\[[^\[\]]*\]/, '');
        // remove the () surrounding the link
        ref = ref.replace(/\(|\)/g, '');
        // e.g. [desc](link.md) gets turned into link.md
        return {
            type: RefType.Hyperlink,
            word: ref,
            hasExtension: exports.refHasExtension(ref),
            range: range,
        };
    }
    if (BibTeXCitations_1.BibTeXCitations.isBibtexFileConfigured()) {
        regex = BibTeXCitations_1.BibTeXCitations.rxBibTeX();
        range = document.getWordRangeAtPosition(position, regex);
        if (range) {
            ref = document.getText(range);
            if (ref) {
                return {
                    type: RefType.BibTeX,
                    word: ref.replace(/^\@+/, ''),
                    hasExtension: null,
                    range: range,
                };
            }
        }
    }
    return exports.NULL_REF;
}
exports.getRefAt = getRefAt;
/*
Similar to getRefAt, but handles the 'empty' Ref cases,
  [[ and # and @
    ^     ^     ^
when they are not followed by any letter chars.
Returns a Ref with the correct type and 0 length range.
*/
function getEmptyRefAt(document, position) {
    // we still need to handle the case where we have the cursor
    // directly after [[ chars with NO letters after the [[
    let c = Math.max(0, position.character - 2); // 2 chars left, unless we are at the 0 or 1 char
    let s = new vscode.Position(position.line, c);
    let searchRange = new vscode.Range(s, position);
    let precedingChars = document.getText(searchRange);
    if (precedingChars == '[[') {
        return {
            type: RefType.WikiLink,
            word: '',
            hasExtension: false,
            // we DO NOT want the replacement position to include the brackets:
            range: new vscode.Range(position, position),
        };
    }
    if (precedingChars == '@') {
        return {
            type: RefType.BibTeX,
            word: '',
            hasExtension: false,
            // we DO NOT want the replacement position to include the @:
            range: new vscode.Range(position, position),
        };
    }
    let regex = NoteWorkspace_1.NoteWorkspace.rxBeginTag();
    if (precedingChars.match(regex)) {
        return {
            type: RefType.Tag,
            word: '',
            hasExtension: false,
            // we DO want the replacement position to include the #:
            range: new vscode.Range(position.translate(0, -1), position),
        };
    }
    return exports.NULL_REF;
}
exports.getEmptyRefAt = getEmptyRefAt;
function getRefOrEmptyRefAt(document, position) {
    let ref = getRefAt(document, position);
    if (ref.type == RefType.Null) {
        ref = getEmptyRefAt(document, position);
    }
    return ref;
}
exports.getRefOrEmptyRefAt = getRefOrEmptyRefAt;
exports.refHasExtension = (word) => {
    return !!word.match(NoteWorkspace_1.NoteWorkspace.rxFileExtensions());
};
exports.refFromWikiLinkText = (wikiLinkText) => {
    return {
        type: RefType.WikiLink,
        word: wikiLinkText,
        hasExtension: exports.refHasExtension(wikiLinkText),
        range: undefined,
    };
};
//# sourceMappingURL=Ref.js.map