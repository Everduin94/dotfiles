"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const foam_core_1 = require("foam-core");
const test_utils_1 = require("../test/test-utils");
const placeholders_1 = require("./placeholders");
describe('isPlaceholderResource', () => {
    it('should return true when a placeholder', () => {
        const noteA = test_utils_1.createTestNote({
            uri: 'note-a.md',
            text: '',
            links: [{ slug: 'placeholder' }],
        });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(foam_core_1.URI.placeholder('placeholder'), ws)).toBeTruthy();
    });
    it('should return true when an empty note is provided', () => {
        const noteA = test_utils_1.createTestNote({ uri: 'note-a.md', text: '' });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(noteA.uri, ws)).toBeTruthy();
    });
    it('should return true when a note containing only whitespace is provided', () => {
        const noteA = test_utils_1.createTestNote({
            uri: '',
            text: ' \n\t\n\t  ',
        });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(noteA.uri, ws)).toBeTruthy();
    });
    it('should return true when a note containing only a title is provided', () => {
        const noteA = test_utils_1.createTestNote({
            uri: '',
            text: '# Title',
        });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(noteA.uri, ws)).toBeTruthy();
    });
    it('should return true when a note containing a title followed by whitespace is provided', () => {
        const noteA = test_utils_1.createTestNote({
            uri: '',
            text: '# Title \n\t\n \t \n  ',
        });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(noteA.uri, ws)).toBeTruthy();
    });
    it('should return false when there is more than one line containing more than just whitespace', () => {
        const noteA = test_utils_1.createTestNote({
            uri: '',
            text: '# Title\nA line that is not the title\nAnother line',
        });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(noteA.uri, ws)).toBeFalsy();
    });
    it('should return false when there is at least one line of non-text content', () => {
        const noteA = test_utils_1.createTestNote({
            uri: '',
            text: 'A line that is not the title\n',
        });
        const ws = new foam_core_1.FoamWorkspace().set(noteA);
        expect(placeholders_1.isPlaceholderResource(noteA.uri, ws)).toBeFalsy();
    });
});
//# sourceMappingURL=placeholders.test.js.map