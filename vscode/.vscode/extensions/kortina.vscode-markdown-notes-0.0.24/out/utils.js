"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.titleCaseFromFilename = exports.titleCase = exports.capitalize = void 0;
// capitalize a single word
exports.capitalize = (word) => {
    if (!word) {
        return word;
    }
    return `${word[0].toUpperCase()}${word.slice(1)}`;
};
// take "a string in some case" to "A String in Title Case"
exports.titleCase = (sentence) => {
    if (!sentence) {
        return sentence;
    }
    const chicagoStyleNoCap = `
a aboard about above across after against along amid among an and anti around as at before behind
below beneath beside besides between beyond but by concerning considering despite down during except
excepting excluding following for from in inside into like minus near of off on onto opposite or
outside over past per plus regarding round save since so than the through to toward towards under
underneath unlike until up upon versus via with within without yet
  `.split(/\s/);
    let words = sentence.split(/\s/);
    return words
        .map((word, i) => {
        if (i == 0 || i == words.length - 1) {
            return exports.capitalize(word);
        }
        else if (chicagoStyleNoCap.includes(word.toLocaleLowerCase())) {
            return word;
        }
        else {
            return exports.capitalize(word);
        }
    })
        .join(' ');
};
// take some-filename-in-case to "Some Filename in Case" Title
exports.titleCaseFromFilename = (filename) => {
    if (!filename) {
        return filename;
    }
    return exports.titleCase(filename
        .replace(/\.(md|markdown)$/, '')
        .replace(/[-_]/gi, ' ')
        .replace(/\s+/, ' '));
};
//# sourceMappingURL=utils.js.map