"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.features = void 0;
const wikilink_reference_generation_1 = __importDefault(require("./wikilink-reference-generation"));
const open_daily_note_1 = __importDefault(require("./open-daily-note"));
const janitor_1 = __importDefault(require("./janitor"));
const dataviz_1 = __importDefault(require("./dataviz"));
const copy_without_brackets_1 = __importDefault(require("./copy-without-brackets"));
const open_dated_note_1 = __importDefault(require("./open-dated-note"));
const tags_tree_view_1 = __importDefault(require("./tags-tree-view"));
const create_from_template_1 = __importDefault(require("./create-from-template"));
const open_random_note_1 = __importDefault(require("./open-random-note"));
const orphans_1 = __importDefault(require("./orphans"));
const placeholders_1 = __importDefault(require("./placeholders"));
const backlinks_1 = __importDefault(require("./backlinks"));
const utility_commands_1 = __importDefault(require("./utility-commands"));
const document_link_provider_1 = __importDefault(require("./document-link-provider"));
const preview_navigation_1 = __importDefault(require("./preview-navigation"));
const link_completion_1 = __importDefault(require("./link-completion"));
const document_decorator_1 = __importDefault(require("./document-decorator"));
exports.features = [
    tags_tree_view_1.default,
    wikilink_reference_generation_1.default,
    open_daily_note_1.default,
    open_random_note_1.default,
    janitor_1.default,
    dataviz_1.default,
    copy_without_brackets_1.default,
    open_dated_note_1.default,
    create_from_template_1.default,
    orphans_1.default,
    placeholders_1.default,
    backlinks_1.default,
    document_link_provider_1.default,
    utility_commands_1.default,
    document_decorator_1.default,
    preview_navigation_1.default,
    link_completion_1.default,
];
//# sourceMappingURL=index.js.map