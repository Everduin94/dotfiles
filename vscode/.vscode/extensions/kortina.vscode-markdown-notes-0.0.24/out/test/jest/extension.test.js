"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
require("jest");
const NoteWorkspace_1 = require("../../NoteWorkspace");
const utils_1 = require("../../utils");
const NoteParser_1 = require("../../NoteParser");
const Ref_1 = require("../../Ref");
const BibTeXCitations_1 = require("../../BibTeXCitations");
// import { config } from 'process';
jest.mock('../../NoteWorkspace');
// set the NoteWorkspace cfg object in a test
// NB: anything not set will inherit from DEFAULT_CONFIG
const setConfig = (cfg) => {
    NoteWorkspace_1.NoteWorkspace.cfg = () => {
        return Object.assign(Object.assign({}, NoteWorkspace_1.NoteWorkspace.DEFAULT_CONFIG), cfg);
    };
};
// reset the cfg to DEFAULT_CONFIG before every test
beforeEach(() => {
    NoteWorkspace_1.NoteWorkspace.cfg = () => {
        return NoteWorkspace_1.NoteWorkspace.DEFAULT_CONFIG;
    };
    BibTeXCitations_1.BibTeXCitations.cfg = () => {
        return {
            bibTeXFilePath: "test/library.bib"
        };
    };
});
test('foo', () => {
    expect(NoteWorkspace_1.foo()).toBe(1);
});
describe('NoteWorkspace.slug', () => {
    test('slugifyMethod', () => {
        setConfig({ slugifyMethod: NoteWorkspace_1.SlugifyMethod.github });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle("Don't Let Go!!")).toEqual('dont-let-go.md');
        NoteWorkspace_1.NoteWorkspace.slugifyMethod = () => NoteWorkspace_1.SlugifyMethod.classic;
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle("Don't Let Go!!")).toEqual('don-t-let-go.md');
    });
    test('noteFileNameFromTitle', () => {
        setConfig({ slugifyCharacter: NoteWorkspace_1.NoteWorkspace.SLUGIFY_NONE, lowercaseNewNoteFilenames: true });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some Title')).toEqual('some title.md');
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some Title ')).toEqual('some title.md');
        setConfig({ slugifyCharacter: NoteWorkspace_1.NoteWorkspace.SLUGIFY_NONE, lowercaseNewNoteFilenames: false });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some Title')).toEqual('Some Title.md');
        setConfig({ slugifyCharacter: '-', lowercaseNewNoteFilenames: true });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some " Title ')).toEqual('some-title.md');
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Šömè Țítlê')).toEqual('šömè-țítlê.md');
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('題目')).toEqual('題目.md');
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some \r \n Title')).toEqual('some-title.md');
        setConfig({ slugifyCharacter: '-', lowercaseNewNoteFilenames: false });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some " Title ')).toEqual('Some-Title.md');
        setConfig({ slugifyCharacter: '_', lowercaseNewNoteFilenames: true });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some   Title ')).toEqual('some_title.md');
        setConfig({ slugifyCharacter: '_', lowercaseNewNoteFilenames: false });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Some   Title ')).toEqual('Some_Title.md');
        setConfig({ slugifyCharacter: '－', lowercaseNewNoteFilenames: true });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Ｓｏｍｅ　Ｔｉｔｌｅ')).toEqual('ｓｏｍｅ－ｔｉｔｌｅ.md');
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Ｓｏｍｅ　Ｔｉｔｌｅ ')).toEqual('ｓｏｍｅ－ｔｉｔｌｅ.md');
        setConfig({ slugifyCharacter: '－', lowercaseNewNoteFilenames: false });
        expect(NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle('Ｓｏｍｅ　Ｔｉｔｌｅ ')).toEqual('Ｓｏｍｅ－Ｔｉｔｌｅ.md');
    });
});
describe('NoteWorkspace.noteNamesFuzzyMatch', () => {
    test('noteNamesFuzzyMatch', () => {
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/the-heat-is-on.md', 'the-heat-is-on.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/the-heat-is-on.md', 'the-heat-is-on')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/the-heat-is-on.markdown', 'the-heat-is-on')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('[[wiki-link.md]]', 'wiki-link.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('[[wiki-link]]', 'wiki-link.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('[[wiki link]]', 'wiki-link.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('[[链接]]', '链接.md')).toBeTruthy();
        // TODO: if we add support for #headings, we will want these tests to pass:
        // expect(NoteWorkspace.noteNamesFuzzyMatch('[[wiki-link.md#with-heading]]', 'wiki-link.md')).toBeTruthy();
        // expect(NoteWorkspace.noteNamesFuzzyMatch('[[wiki-link#with-heading]]', 'wiki-link.md')).toBeTruthy();
        // expect(NoteWorkspace.noteNamesFuzzyMatch('[[wiki link#with-heading]]', 'wiki-link.md')).toBeTruthy();
    });
    test('noteNamesFuzzyMatchSlashes', () => {
        expect(NoteWorkspace_1.NoteWorkspace.normalizeNoteNameForFuzzyMatch('dir/sub/link-topic.md')).toEqual('link-topic');
        // lower case is expected because 'slugifyTitle' includes toLowerCase
        expect(NoteWorkspace_1.NoteWorkspace.slugifyTitle('Link/Topic')).toEqual('link-topic');
        expect(NoteWorkspace_1.NoteWorkspace.normalizeNoteNameForFuzzyMatchText('Link/Topic')).toEqual('link-topic');
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/link-topic.md', 'Link/Topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/Link-Topic.md', 'Link/Topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/link-topic.md', 'link/topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/Link-Topic.md', 'link/topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/link-topic.md', 'Link/topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/link-topic.md', 'link/Topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/Link-Topic.md', 'Link/topic')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('dir/sub/Link-Topic.md', 'link/Topic')).toBeTruthy();
    });
    test('noteNamesFuzzyMatch', () => {
        expect(NoteWorkspace_1.NoteWorkspace._wikiLinkCompletionForConvention('toSpaces', 'the-note-name.md')).toEqual('the note name');
        expect(NoteWorkspace_1.NoteWorkspace._wikiLinkCompletionForConvention('noExtension', 'the-note-name.md')).toEqual('the-note-name');
        expect(NoteWorkspace_1.NoteWorkspace._wikiLinkCompletionForConvention('rawFilename', 'the-note-name.md')).toEqual('the-note-name.md');
        // TODO: how should this behaving with #headings?
    });
});
describe('NoteWorkspace.rx', () => {
    test('rxWikiLink', () => {
        let rx = NoteWorkspace_1.NoteWorkspace.rxWikiLink();
        expect(('Some [[wiki-link]].'.match(rx) || [])[0]).toEqual('[[wiki-link]]');
        expect(('Some [[wiki link]].'.match(rx) || [])[0]).toEqual('[[wiki link]]');
        expect(('一段 [[链接]]。'.match(rx) || [])[0]).toEqual('[[链接]]');
        expect(('Some [[wiki-link.md]].'.match(rx) || [])[0]).toEqual('[[wiki-link.md]]');
        expect(('一段 [[链接.md]]。'.match(rx) || [])[0]).toEqual('[[链接.md]]');
        // TODO: this returns a match OK right now, but I think we will want to
        // modify the result to contain meta-data that says there is also a #heading / parses it out
        expect(('Some [[wiki-link.md#with-heading]].'.match(rx) || [])[0]).toEqual('[[wiki-link.md#with-heading]]');
        // Should the following work? It does....
        expect(('Some[[wiki-link.md]]no-space.'.match(rx) || [])[0]).toEqual('[[wiki-link.md]]');
        expect(('一段[[链接]]无空格。'.match(rx) || [])[0]).toEqual('[[链接]]');
        expect('Some [[wiki-link.md].').not.toMatch(rx);
    });
    test('rxTag', () => {
        let rx = NoteWorkspace_1.NoteWorkspace.rxTag();
        // preceded by space:
        expect(('http://something/ something #draft middle.'.match(rx) || [])[0]).toEqual('#draft');
        expect(('http://something/ something end #draft'.match(rx) || [])[0]).toEqual('#draft');
        expect(('http://something/ #draft.'.match(rx) || [])[0]).toEqual('#draft');
        // preceded by comma:
        expect((',#draft,'.match(rx) || [])[0]).toEqual('#draft');
        // start of line:
        expect(('#draft start'.match(rx) || [])[0]).toEqual('#draft');
        // the character before the match needs to be a space or start of line:
        expect('[site](http://something/#com).').not.toMatch(rx);
        expect('[site](https://something.com/?q=v#com).').not.toMatch(rx);
    });
    test('rxBeginTag', () => {
        let rx = NoteWorkspace_1.NoteWorkspace.rxBeginTag();
        // preceded by space:
        expect((' #...'.match(rx) || [])[0]).toEqual('#');
        expect((' #draft...'.match(rx) || [])[0]).toEqual('#');
        // preceded by comma:
        expect((',#...'.match(rx) || [])[0]).toEqual('#');
        // start of line:
        expect(('#...'.match(rx) || [])[0]).toEqual('#');
        // the character before the match needs to be a space or start of line:
        expect('https://something.com/?q=v#com').not.toMatch(rx);
    });
    test('rxMarkdownHyperlink', () => {
        let rx = NoteWorkspace_1.NoteWorkspace.rxMarkdownHyperlink();
        // "regular" use of link:
        expect(('Some link to [test](test.md).'.match(rx) || [])[0]).toEqual('[test](test.md)');
        // no description:
        expect(('Some link to [](test.md).'.match(rx) || [])[0]).toEqual('[](test.md)');
        // empty link:
        expect('Some link to nowhere []().').not.toMatch(rx);
        // link to a website:
        expect('Some link to [google](https://google.com).').not.toMatch(rx);
    });
});
describe('BibTeXCitations', () => {
    test("rxBibTeX", () => {
        let rx = BibTeXCitations_1.BibTeXCitations.rxBibTeX();
        // start of line
        expect(("@reference".match(rx) || [])[0]).toEqual("@reference");
        expect(("@author_title_2010".match(rx) || [])[0]).toEqual("@author_title_2010");
        // preceded by space:
        expect(("http://something/ something @ref middle.".match(rx) || [])[0]).toEqual("@ref");
        expect(("http://something/ something end @ref".match(rx) || [])[0]).toEqual("@ref");
        // preceded by comma:
        expect((",@ref,".match(rx) || [])[0]).toEqual("@ref");
        // at the end of sentence
        expect(("some @reference. another".match(rx) || [])[0]).toEqual("@reference");
        // at the end of string
        expect(("some @reference.".match(rx) || [])[0]).toEqual("@reference");
        // inside brackets with name supression
        expect(("some [-@reference]".match(rx) || [])[0]).toEqual("@reference");
        // do not match email address
        expect("name@domain.com").not.toMatch(rx);
    });
    test("references", () => __awaiter(void 0, void 0, void 0, function* () {
        const refs = yield BibTeXCitations_1.BibTeXCitations.citations();
        expect(refs).toEqual([
            "clear_zettelkasten_2020",
            "kleppmann_designing_2016",
            "nagel_what_1974",
            "turing_computing_1950"
        ]);
    }));
});
let document = `line0 word1
line1 word1 word2 
  [[test.md]]  #tag #another_tag  <- link at line2, chars 2-12
^ tags at line2 chars 15-19 and 21-32
[[test.md]] <- link at line4, chars 0-11
[[demo.md]] <- link at line5, chars 0-11
#tag word <- line 6, chars 0-3
# [[]] [[ <- line 7, empty refs
[](test-hyperlink.md) <- link at line8, chars 0-11
[]() [](`; // line 9, empty refs
describe('Note', () => {
    test('Note._rawRangesForWord', () => {
        let w = {
            word: 'test.md',
            hasExtension: true,
            type: Ref_1.RefType.WikiLink,
            range: undefined,
        };
        let ranges;
        ranges = NoteParser_1.Note.fromData(document)._rawRangesForWord(w);
        expect(ranges).toMatchObject([
            { start: { line: 2, character: 2 }, end: { line: 2, character: 13 } },
            { start: { line: 4, character: 0 }, end: { line: 4, character: 11 } },
        ]);
        w = {
            word: 'tag',
            hasExtension: true,
            type: Ref_1.RefType.Tag,
            range: undefined,
        };
        ranges = NoteParser_1.Note.fromData(document)._rawRangesForWord(w);
        expect(ranges).toMatchObject([
            { start: { line: 2, character: 15 }, end: { line: 2, character: 19 } },
            { start: { line: 6, character: 0 }, end: { line: 6, character: 4 } },
        ]);
        w = {
            word: 'another_tag',
            hasExtension: true,
            type: Ref_1.RefType.Tag,
            range: undefined,
        };
        ranges = NoteParser_1.Note.fromData(document)._rawRangesForWord(w);
        expect(ranges).toMatchObject([
            { start: { line: 2, character: 20 }, end: { line: 2, character: 32 } },
        ]);
        w = {
            word: 'test-hyperlink.md',
            hasExtension: true,
            type: Ref_1.RefType.Hyperlink,
            range: undefined,
        };
        ranges = NoteParser_1.Note.fromData(document)._rawRangesForWord(w);
        expect(ranges).toMatchObject([
            { start: { line: 8, character: 0 }, end: { line: 8, character: 21 } },
        ]);
    });
    test('Note.tagSet', () => {
        let tags = NoteParser_1.Note.fromData(document).tagSet();
        expect(tags).toEqual(new Set(['#another_tag', '#tag']));
    });
});
describe('NoteWorkspace.pipedWikiLinks', () => {
    beforeEach(() => {
        setConfig({
            allowPipedWikiLinks: true,
            pipedWikiLinksSyntax: NoteWorkspace_1.PipedWikiLinksSyntax.descFile,
        });
    });
    test('cleanPipedWikiLinks', () => {
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('description|file')).toEqual('file');
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('description with lots of spaces, and other symbols|file.md')).toEqual('file.md');
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('description|file')).toEqual('file');
        // Odd case, but I suppose it should be treated
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('description|file|but-with-a-pipe-symbol.md')).toEqual('file|but-with-a-pipe-symbol.md');
    });
    test('noteNamesFuzzyMatch, SlugifyMethod.github', () => {
        // inherit the config set in describe:beforeEach
        setConfig(Object.assign(Object.assign({}, NoteWorkspace_1.NoteWorkspace.cfg()), { slugifyMethod: NoteWorkspace_1.SlugifyMethod.github }));
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'description|filename.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'description |filename.md')).toBeTruthy();
    });
    test('noteNamesFuzzyMatch, SlugifyMethod.classic', () => {
        // inherit the config set in describe:beforeEach
        setConfig(Object.assign(Object.assign({}, NoteWorkspace_1.NoteWorkspace.cfg()), { slugifyMethod: NoteWorkspace_1.SlugifyMethod.classic }));
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'description|filename.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'description |filename.md')).toBeTruthy();
    });
    test('allowPipedWikiLinks false', () => {
        setConfig({
            allowPipedWikiLinks: false,
            pipedWikiLinksSyntax: NoteWorkspace_1.PipedWikiLinksSyntax.descFile,
        });
        // Because of this change, these should not match anymore...
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'description|filename.md')).toBeFalsy();
        // ... And cleanPipedWikiLink should return the original string.
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('description|file')).toEqual('description|file');
    });
    test('pipedWikiLinksSeparator custom', () => {
        setConfig({
            allowPipedWikiLinks: true,
            pipedWikiLinksSyntax: NoteWorkspace_1.PipedWikiLinksSyntax.descFile,
            pipedWikiLinksSeparator: '@',
        });
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'description@filename.md')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('description@file')).toEqual('file');
    });
    test('PipedWikiLinksSyntax.fileDesc', () => {
        setConfig({
            allowPipedWikiLinks: true,
            pipedWikiLinksSyntax: NoteWorkspace_1.PipedWikiLinksSyntax.fileDesc,
            pipedWikiLinksSeparator: '\\|',
        });
        expect(NoteWorkspace_1.NoteWorkspace.noteNamesFuzzyMatch('filename.md', 'filename.md|description')).toBeTruthy();
        expect(NoteWorkspace_1.NoteWorkspace.cleanPipedWikiLink('file|description')).toEqual('file');
    });
});
describe('NoteWorkspace.newNoteContent', () => {
    const newNote = (template, title) => {
        setConfig({
            newNoteTemplate: template,
        });
        return NoteWorkspace_1.NoteWorkspace.newNoteContent(title);
    };
    it('handles noteName tag', () => {
        const template = '# ${noteName}\n\nThis is ${noteName}';
        const content = newNote(template, 'this is my test note!');
        expect(content).toBe('# this is my test note!\n\nThis is this is my test note!');
    });
    it('handles escaped newlines', () => {
        const template = '# Title\\n\\nContent';
        const content = newNote(template, 'nevermind');
        expect(content).toBe('# Title\n\nContent');
    });
    it('handles timestamp', () => {
        const template = '# Title\n\nCreated: ${timestamp}\n';
        const content = newNote(template, 'nevermind');
        const regex = /# Title\n\nCreated: (.*)\n/;
        expect(content).toMatch(regex);
        const matches = regex.exec(content);
        const date1 = Date.parse(matches[1]);
        expect(date1).not.toBe(Number.NaN);
    });
    it('handles date', () => {
        const template = '# Title\nDate: ${date}\n';
        const content = newNote(template, 'nevermind');
        const d = (new Date().toISOString().match(/(\d{4}-\d{2}-\d{2})/) || '')[0];
        const dt = `Date: ${d}`;
        expect(content.includes(dt)).toBeTruthy();
    });
});
describe('utils', () => {
    test('titleCaseFromFilename', () => {
        expect(utils_1.titleCaseFromFilename('the-heat-is-on.md')).toEqual('The Heat Is On');
        expect(utils_1.titleCaseFromFilename('in-the-heat-of-the-night.md')).toEqual('In the Heat of the Night');
    });
});
//# sourceMappingURL=extension.test.js.map