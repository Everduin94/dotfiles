"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.markdownItWithRemoveLinkReferences = exports.markdownItWithFoamTags = exports.markdownItWithFoamLinks = void 0;
const foam_core_1 = require("foam-core");
const markdown_it_regex_1 = __importDefault(require("markdown-it-regex"));
const utils_1 = require("../utils");
const ALIAS_DIVIDER_CHAR = '|';
const feature = {
    activate: async (_context, foamPromise) => {
        const foam = await foamPromise;
        return {
            extendMarkdownIt: (md) => {
                return [
                    exports.markdownItWithFoamTags,
                    exports.markdownItWithFoamLinks,
                    exports.markdownItWithRemoveLinkReferences,
                ].reduce((acc, extension) => extension(acc, foam.workspace), md);
            },
        };
    },
};
exports.markdownItWithFoamLinks = (md, workspace) => {
    return md.use(markdown_it_regex_1.default, {
        name: 'connect-wikilinks',
        regex: /\[\[([^[\]]+?)\]\]/,
        replace: (wikilink) => {
            try {
                const linkHasAlias = wikilink.includes(ALIAS_DIVIDER_CHAR);
                const resourceLink = linkHasAlias
                    ? wikilink.substring(0, wikilink.indexOf('|'))
                    : wikilink;
                const resource = workspace.find(resourceLink);
                if (utils_1.isNone(resource)) {
                    return getPlaceholderLink(resourceLink);
                }
                const linkLabel = linkHasAlias
                    ? wikilink.substr(wikilink.indexOf('|') + 1)
                    : wikilink;
                return `<a class='foam-note-link' title='${resource.title}' href='${foam_core_1.URI.toFsPath(resource.uri)}' data-href='${foam_core_1.URI.toFsPath(resource.uri)}'>${linkLabel}</a>`;
            }
            catch (e) {
                foam_core_1.Logger.error(`Error while creating link for [[${wikilink}]] in Preview panel`, e);
                return getPlaceholderLink(wikilink);
            }
        },
    });
};
const getPlaceholderLink = (content) => `<a class='foam-placeholder-link' title="Link to non-existing resource" href="javascript:void(0);">${content}</a>`;
exports.markdownItWithFoamTags = (md, workspace) => {
    return md.use(markdown_it_regex_1.default, {
        name: 'foam-tags',
        regex: /(#\w+)/,
        replace: (tag) => {
            try {
                const resource = workspace.find(tag);
                if (utils_1.isNone(resource)) {
                    return getFoamTag(tag);
                }
            }
            catch (e) {
                foam_core_1.Logger.error(`Error while creating link for ${tag} in Preview panel`, e);
                return getFoamTag(tag);
            }
        },
    });
};
const getFoamTag = (content) => `<span class='foam-tag'>${content}</span>`;
exports.markdownItWithRemoveLinkReferences = (md, workspace) => {
    // Forget about reference links that contain an alias divider
    md.inline.ruler.before('link', 'clear-references', state => {
        if (state.env.references) {
            Object.keys(state.env.references).forEach(refKey => {
                if (refKey.includes(ALIAS_DIVIDER_CHAR)) {
                    delete state.env.references[refKey];
                }
            });
        }
        return false;
    });
    return md;
};
exports.default = feature;
//# sourceMappingURL=preview-navigation.js.map