"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GroupedResoucesConfigGroupBy = exports.getPlaceholdersConfig = exports.getOrphansConfig = exports.getFoamLoggerLevel = exports.getGraphStyle = exports.getTitleMaxLength = exports.getIgnoredFilesSetting = exports.getWikilinkDefinitionSetting = exports.LinkReferenceDefinitionsSetting = void 0;
const vscode_1 = require("vscode");
var LinkReferenceDefinitionsSetting;
(function (LinkReferenceDefinitionsSetting) {
    LinkReferenceDefinitionsSetting["withExtensions"] = "withExtensions";
    LinkReferenceDefinitionsSetting["withoutExtensions"] = "withoutExtensions";
    LinkReferenceDefinitionsSetting["off"] = "off";
})(LinkReferenceDefinitionsSetting = exports.LinkReferenceDefinitionsSetting || (exports.LinkReferenceDefinitionsSetting = {}));
function getWikilinkDefinitionSetting() {
    return vscode_1.workspace
        .getConfiguration('foam.edit')
        .get('linkReferenceDefinitions', LinkReferenceDefinitionsSetting.withoutExtensions);
}
exports.getWikilinkDefinitionSetting = getWikilinkDefinitionSetting;
/** Retrieve the list of file ignoring globs. */
function getIgnoredFilesSetting() {
    return [
        ...vscode_1.workspace.getConfiguration().get('foam.files.ignore', []),
        ...Object.keys(vscode_1.workspace.getConfiguration().get('files.exclude', {})),
    ];
}
exports.getIgnoredFilesSetting = getIgnoredFilesSetting;
/** Retrieves the maximum length for a Graph node title. */
function getTitleMaxLength() {
    return vscode_1.workspace.getConfiguration('foam.graph').get('titleMaxLength');
}
exports.getTitleMaxLength = getTitleMaxLength;
/** Retrieve the graph's style object */
function getGraphStyle() {
    return vscode_1.workspace.getConfiguration('foam.graph').get('style');
}
exports.getGraphStyle = getGraphStyle;
function getFoamLoggerLevel() {
    var _a;
    return (_a = vscode_1.workspace.getConfiguration('foam.logging').get('level')) !== null && _a !== void 0 ? _a : 'info';
}
exports.getFoamLoggerLevel = getFoamLoggerLevel;
/** Retrieve the orphans configuration */
function getOrphansConfig() {
    const orphansConfig = vscode_1.workspace.getConfiguration('foam.orphans');
    const exclude = orphansConfig.get('exclude');
    const groupBy = orphansConfig.get('groupBy');
    return { exclude, groupBy };
}
exports.getOrphansConfig = getOrphansConfig;
/** Retrieve the placeholders configuration */
function getPlaceholdersConfig() {
    const placeholderCfg = vscode_1.workspace.getConfiguration('foam.placeholders');
    const exclude = placeholderCfg.get('exclude');
    const groupBy = placeholderCfg.get('groupBy');
    return { exclude, groupBy };
}
exports.getPlaceholdersConfig = getPlaceholdersConfig;
var GroupedResoucesConfigGroupBy;
(function (GroupedResoucesConfigGroupBy) {
    GroupedResoucesConfigGroupBy["Folder"] = "folder";
    GroupedResoucesConfigGroupBy["Off"] = "off";
})(GroupedResoucesConfigGroupBy = exports.GroupedResoucesConfigGroupBy || (exports.GroupedResoucesConfigGroupBy = {}));
//# sourceMappingURL=settings.js.map