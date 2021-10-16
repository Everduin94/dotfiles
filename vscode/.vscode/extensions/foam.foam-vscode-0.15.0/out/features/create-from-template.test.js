"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const create_from_template_1 = require("./create-from-template");
const path_1 = __importDefault(require("path"));
const utils_1 = require("../utils");
const foam_core_1 = require("foam-core");
describe('substituteFoamVariables', () => {
    test('Does nothing if no Foam-specific variables are used', () => {
        const input = `
      # \${AnotherVariable} <-- Unrelated to foam
      # \${AnotherVariable:default_value} <-- Unrelated to foam
      # \${AnotherVariable:default_value/(.*)/\${1:/upcase}/}} <-- Unrelated to foam
      # $AnotherVariable} <-- Unrelated to foam
      # $CURRENT_YEAR-\${CURRENT_MONTH}-$CURRENT_DAY <-- Unrelated to foam
    `;
        const givenValues = new Map();
        givenValues.set('FOAM_TITLE', 'My note title');
        expect(create_from_template_1.substituteFoamVariables(input, givenValues)).toEqual(input);
    });
    test('Correctly substitutes variables that are substrings of one another', () => {
        // FOAM_TITLE is a substring of FOAM_TITLE_NON_EXISTENT_VARIABLE
        // If we're not careful with how we substitute the values
        // we can end up putting the FOAM_TITLE in place FOAM_TITLE_NON_EXISTENT_VARIABLE should be.
        const input = `
      # \${FOAM_TITLE}
      # $FOAM_TITLE
      # \${FOAM_TITLE_NON_EXISTENT_VARIABLE}
      # $FOAM_TITLE_NON_EXISTENT_VARIABLE
    `;
        const expected = `
      # My note title
      # My note title
      # \${FOAM_TITLE_NON_EXISTENT_VARIABLE}
      # $FOAM_TITLE_NON_EXISTENT_VARIABLE
    `;
        const givenValues = new Map();
        givenValues.set('FOAM_TITLE', 'My note title');
        expect(create_from_template_1.substituteFoamVariables(input, givenValues)).toEqual(expected);
    });
});
describe('resolveFoamVariables', () => {
    test('Does nothing for unknown Foam-specific variables', async () => {
        const variables = ['FOAM_FOO'];
        const expected = new Map();
        expected.set('FOAM_FOO', 'FOAM_FOO');
        const givenValues = new Map();
        expect(await create_from_template_1.resolveFoamVariables(variables, givenValues)).toEqual(expected);
    });
    test('Resolves FOAM_TITLE', async () => {
        const foamTitle = 'My note title';
        const variables = ['FOAM_TITLE'];
        jest
            .spyOn(vscode_1.window, 'showInputBox')
            .mockImplementationOnce(jest.fn(() => Promise.resolve(foamTitle)));
        const expected = new Map();
        expected.set('FOAM_TITLE', foamTitle);
        const givenValues = new Map();
        expect(await create_from_template_1.resolveFoamVariables(variables, givenValues)).toEqual(expected);
    });
    test('Resolves FOAM_TITLE without asking the user when it is provided', async () => {
        const foamTitle = 'My note title';
        const variables = ['FOAM_TITLE'];
        const expected = new Map();
        expected.set('FOAM_TITLE', foamTitle);
        const givenValues = new Map();
        givenValues.set('FOAM_TITLE', foamTitle);
        expect(await create_from_template_1.resolveFoamVariables(variables, givenValues)).toEqual(expected);
    });
});
describe('resolveFoamTemplateVariables', () => {
    test('Does nothing for template without Foam-specific variables', async () => {
        const input = `
      # \${AnotherVariable} <-- Unrelated to foam
      # \${AnotherVariable:default_value} <-- Unrelated to foam
      # \${AnotherVariable:default_value/(.*)/\${1:/upcase}/}} <-- Unrelated to foam
      # $AnotherVariable} <-- Unrelated to foam
      # $CURRENT_YEAR-\${CURRENT_MONTH}-$CURRENT_DAY <-- Unrelated to foam
    `;
        const expectedMap = new Map();
        const expectedString = input;
        const expected = [expectedMap, expectedString];
        expect(await create_from_template_1.resolveFoamTemplateVariables(input)).toEqual(expected);
    });
    test('Does nothing for unknown Foam-specific variables', async () => {
        const input = `
      # $FOAM_FOO
      # \${FOAM_FOO}
      # \${FOAM_FOO:default_value}
      # \${FOAM_FOO:default_value/(.*)/\${1:/upcase}/}}
    `;
        const expectedMap = new Map();
        const expectedString = input;
        const expected = [expectedMap, expectedString];
        expect(await create_from_template_1.resolveFoamTemplateVariables(input)).toEqual(expected);
    });
    test('Allows extra variables to be provided; only resolves the unique set', async () => {
        const foamTitle = 'My note title';
        jest
            .spyOn(vscode_1.window, 'showInputBox')
            .mockImplementationOnce(jest.fn(() => Promise.resolve(foamTitle)));
        const input = `
      # $FOAM_TITLE
    `;
        const expectedOutput = `
      # My note title
    `;
        const expectedMap = new Map();
        expectedMap.set('FOAM_TITLE', foamTitle);
        const expected = [expectedMap, expectedOutput];
        expect(await create_from_template_1.resolveFoamTemplateVariables(input, new Set(['FOAM_TITLE']))).toEqual(expected);
    });
    test('Appends FOAM_SELECTED_TEXT with a newline to the template if there is selected text but FOAM_SELECTED_TEXT is not referenced and the template ends in a newline', async () => {
        const foamTitle = 'My note title';
        jest
            .spyOn(vscode_1.window, 'showInputBox')
            .mockImplementationOnce(jest.fn(() => Promise.resolve(foamTitle)));
        const input = `# \${FOAM_TITLE}\n`;
        const expectedOutput = `# My note title\nSelected text\n`;
        const expectedMap = new Map();
        expectedMap.set('FOAM_TITLE', foamTitle);
        expectedMap.set('FOAM_SELECTED_TEXT', 'Selected text');
        const expected = [expectedMap, expectedOutput];
        const givenValues = new Map();
        givenValues.set('FOAM_SELECTED_TEXT', 'Selected text');
        expect(await create_from_template_1.resolveFoamTemplateVariables(input, new Set(['FOAM_TITLE', 'FOAM_SELECTED_TEXT']), givenValues)).toEqual(expected);
    });
    test('Appends FOAM_SELECTED_TEXT with a newline to the template if there is selected text but FOAM_SELECTED_TEXT is not referenced and the template ends in multiple newlines', async () => {
        const foamTitle = 'My note title';
        jest
            .spyOn(vscode_1.window, 'showInputBox')
            .mockImplementationOnce(jest.fn(() => Promise.resolve(foamTitle)));
        const input = `# \${FOAM_TITLE}\n\n`;
        const expectedOutput = `# My note title\n\nSelected text\n`;
        const expectedMap = new Map();
        expectedMap.set('FOAM_TITLE', foamTitle);
        expectedMap.set('FOAM_SELECTED_TEXT', 'Selected text');
        const expected = [expectedMap, expectedOutput];
        const givenValues = new Map();
        givenValues.set('FOAM_SELECTED_TEXT', 'Selected text');
        expect(await create_from_template_1.resolveFoamTemplateVariables(input, new Set(['FOAM_TITLE', 'FOAM_SELECTED_TEXT']), givenValues)).toEqual(expected);
    });
    test('Appends FOAM_SELECTED_TEXT without a newline to the template if there is selected text but FOAM_SELECTED_TEXT is not referenced and the template does not end in a newline', async () => {
        const foamTitle = 'My note title';
        jest
            .spyOn(vscode_1.window, 'showInputBox')
            .mockImplementationOnce(jest.fn(() => Promise.resolve(foamTitle)));
        const input = `# \${FOAM_TITLE}`;
        const expectedOutput = '# My note title\nSelected text';
        const expectedMap = new Map();
        expectedMap.set('FOAM_TITLE', foamTitle);
        expectedMap.set('FOAM_SELECTED_TEXT', 'Selected text');
        const expected = [expectedMap, expectedOutput];
        const givenValues = new Map();
        givenValues.set('FOAM_SELECTED_TEXT', 'Selected text');
        expect(await create_from_template_1.resolveFoamTemplateVariables(input, new Set(['FOAM_TITLE', 'FOAM_SELECTED_TEXT']), givenValues)).toEqual(expected);
    });
    test('Does not append FOAM_SELECTED_TEXT to a template if there is no selected text and is not referenced', async () => {
        const foamTitle = 'My note title';
        jest
            .spyOn(vscode_1.window, 'showInputBox')
            .mockImplementationOnce(jest.fn(() => Promise.resolve(foamTitle)));
        const input = `
      # \${FOAM_TITLE}
      `;
        const expectedOutput = `
      # My note title
      `;
        const expectedMap = new Map();
        expectedMap.set('FOAM_TITLE', foamTitle);
        expectedMap.set('FOAM_SELECTED_TEXT', '');
        const expected = [expectedMap, expectedOutput];
        const givenValues = new Map();
        givenValues.set('FOAM_SELECTED_TEXT', '');
        expect(await create_from_template_1.resolveFoamTemplateVariables(input, new Set(['FOAM_TITLE', 'FOAM_SELECTED_TEXT']), givenValues)).toEqual(expected);
    });
});
describe('determineDefaultFilepath', () => {
    test('Absolute filepath metadata is unchanged', () => {
        const absolutePath = utils_1.isWindows
            ? 'c:\\absolute_path\\journal\\My Note Title.md'
            : '/absolute_path/journal/My Note Title.md';
        const resolvedValues = new Map();
        const templateMetadata = new Map();
        templateMetadata.set('filepath', absolutePath);
        const resultFilepath = create_from_template_1.determineDefaultFilepath(resolvedValues, templateMetadata);
        expect(foam_core_1.URI.toFsPath(resultFilepath)).toMatch(absolutePath);
    });
    test('Relative filepath metadata is appended to current directory', () => {
        const relativePath = utils_1.isWindows
            ? 'journal\\My Note Title.md'
            : 'journal/My Note Title.md';
        const resolvedValues = new Map();
        const templateMetadata = new Map();
        templateMetadata.set('filepath', relativePath);
        const resultFilepath = create_from_template_1.determineDefaultFilepath(resolvedValues, templateMetadata);
        const expectedPath = path_1.default.join(vscode_1.workspace.workspaceFolders[0].uri.fsPath, relativePath);
        expect(foam_core_1.URI.toFsPath(resultFilepath)).toMatch(expectedPath);
    });
});
//# sourceMappingURL=create-from-template.test.js.map