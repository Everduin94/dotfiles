"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const markdown_it_1 = __importDefault(require("markdown-it"));
const foam_core_1 = require("foam-core");
const test_utils_1 = require("../test/test-utils");
const preview_navigation_1 = require("./preview-navigation");
describe('Link generation in preview', () => {
    const noteA = test_utils_1.createTestNote({
        uri: 'note-a.md',
        title: 'My note title',
        links: [{ slug: 'placeholder' }],
    });
    const ws = new foam_core_1.FoamWorkspace().set(noteA);
    const md = preview_navigation_1.markdownItWithFoamLinks(markdown_it_1.default(), ws);
    it('generates a link to a note', () => {
        expect(md.render(`[[note-a]]`)).toEqual(`<p><a class='foam-note-link' title='${noteA.title}' href='${foam_core_1.URI.toFsPath(noteA.uri)}' data-href='${foam_core_1.URI.toFsPath(noteA.uri)}'>note-a</a></p>\n`);
    });
    it('generates a link to a placeholder resource', () => {
        expect(md.render(`[[placeholder]]`)).toEqual(`<p><a class='foam-placeholder-link' title="Link to non-existing resource" href="javascript:void(0);">placeholder</a></p>\n`);
    });
    it('generates a placeholder link to an unknown slug', () => {
        expect(md.render(`[[random-text]]`)).toEqual(`<p><a class='foam-placeholder-link' title="Link to non-existing resource" href="javascript:void(0);">random-text</a></p>\n`);
    });
});
describe('Stylable tag generation in preview', () => {
    const noteB = test_utils_1.createTestNote({
        uri: 'note-b.md',
        title: 'Note B',
    });
    const ws = new foam_core_1.FoamWorkspace().set(noteB);
    const md = preview_navigation_1.markdownItWithFoamTags(markdown_it_1.default(), ws);
    it('transforms a string containing multiple tags to a stylable html element', () => {
        expect(md.render(`Lorem #ipsum dolor #sit`)).toMatch(`<p>Lorem <span class='foam-tag'>#ipsum</span> dolor <span class='foam-tag'>#sit</span></p>`);
    });
});
//# sourceMappingURL=preview-navigation.spec.js.map