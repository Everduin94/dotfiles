"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.pluginSettings = exports.postProcessLabel = exports.postProcessPageName = exports.PageNameGenerator = void 0;
const MarkdownDefinitionProvider_1 = require("./MarkdownDefinitionProvider");
const NoteWorkspace_1 = require("./NoteWorkspace");
const Ref_1 = require("./Ref");
// See also: https://github.com/tomleesm/markdown-it-wikilinks
// Function that returns a filename based on the given wikilink.
// Initially uses filesForWikiLinkRefFromCache() to try and find a matching file.
// If this fails, it will attempt to make a (relative) link based on the label given.
function PageNameGenerator(label) {
    const ref = Ref_1.refFromWikiLinkText(label);
    const results = MarkdownDefinitionProvider_1.MarkdownDefinitionProvider.filesForWikiLinkRefFromCache(ref, null);
    // NB: it is kind of weird that we need to strip the extension here
    // to make noteFileNameFromTitle work,
    // but then noteFileNameFromTitle adds back the default extension...
    // Prolly will lead to some bugs, and maybe we should add an optional
    // extension argument to noteFileNameFromTitle...
    label = NoteWorkspace_1.NoteWorkspace.stripExtension(label);
    // Either use the first result of the cache, or in the case that it's empty use the label to create a path
    let path = results.length != 0 ? results[0].path : NoteWorkspace_1.NoteWorkspace.noteFileNameFromTitle(label);
    return path;
}
exports.PageNameGenerator = PageNameGenerator;
// Transformation that only gets applied to the page name (ex: the "test-file.md" part of [[test-file.md | Description goes here]]).
function postProcessPageName(pageName) {
    return NoteWorkspace_1.NoteWorkspace.stripExtension(pageName);
}
exports.postProcessPageName = postProcessPageName;
// Transformation that only gets applied to the link label (ex: the " Description goes here" part of [[test-file.md | Description goes here]])
function postProcessLabel(label) {
    // Trim whitespaces
    label = label.trim();
    // De-slugify label into white-spaces
    label = label.split(NoteWorkspace_1.NoteWorkspace.slugifyChar()).join(' ');
    if (NoteWorkspace_1.NoteWorkspace.previewShowFileExtension()) {
        label += `.${NoteWorkspace_1.NoteWorkspace.defaultFileExtension()}`;
    }
    switch (NoteWorkspace_1.NoteWorkspace.previewLabelStyling()) {
        case '[[label]]':
            return `[[${label}]]`;
        case '[label]':
            return `[${label}]`;
        case 'label':
            return label;
    }
}
exports.postProcessLabel = postProcessLabel;
function pluginSettings() {
    return require('@thomaskoppelaar/markdown-it-wikilinks')({
        generatePageNameFromLabel: PageNameGenerator,
        postProcessPageName: postProcessPageName,
        postProcessLabel: postProcessLabel,
        uriSuffix: `.${NoteWorkspace_1.NoteWorkspace.defaultFileExtension()}`,
        description_then_file: NoteWorkspace_1.NoteWorkspace.pipedWikiLinksSyntax() == 'desc|file',
        separator: NoteWorkspace_1.NoteWorkspace.pipedWikiLinksSeparator(),
    });
}
exports.pluginSettings = pluginSettings;
//# sourceMappingURL=MarkdownRenderingPlugin.js.map