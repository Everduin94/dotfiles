"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.datesCompletionProvider = void 0;
const vscode_1 = require("vscode");
const dated_notes_1 = require("../dated-notes");
const daysOfWeek = [
    { day: 'sunday', index: 0 },
    { day: 'monday', index: 1 },
    { day: 'tuesday', index: 2 },
    { day: 'wednesday', index: 3 },
    { day: 'thursday', index: 4 },
    { day: 'friday', index: 5 },
    { day: 'saturday', index: 6 },
];
const foamConfig = vscode_1.workspace.getConfiguration('foam');
const foamNavigateOnSelect = foamConfig.get('dateSnippets.afterCompletion');
const generateDayOfWeekSnippets = () => {
    const getTarget = (day) => {
        const target = new Date();
        const currentDay = target.getDay();
        const distance = (day + 7 - currentDay) % 7;
        target.setDate(target.getDate() + distance);
        return target;
    };
    const snippets = daysOfWeek.map(({ day, index }) => {
        const target = getTarget(index);
        return {
            date: target,
            detail: `Get a daily note link for ${day}`,
            snippet: `/${day}`,
        };
    });
    return snippets;
};
const createCompletionItem = ({ snippet, date, detail }) => {
    const completionItem = new vscode_1.CompletionItem(snippet, vscode_1.CompletionItemKind.Snippet);
    completionItem.insertText = getDailyNoteLink(date);
    completionItem.detail = `${completionItem.insertText} - ${detail}`;
    if (foamNavigateOnSelect !== 'noop') {
        completionItem.command = {
            command: 'foam-vscode.open-dated-note',
            title: 'Open a note for the given date',
            arguments: [date],
        };
    }
    return completionItem;
};
const getDailyNoteLink = (date) => {
    const foamExtension = foamConfig.get('openDailyNote.fileExtension');
    const name = dated_notes_1.getDailyNoteFileName(foamConfig, date);
    return `[[${name.replace(`.${foamExtension}`, '')}]]`;
};
const snippetFactories = [
    () => ({
        detail: "Insert a link to today's daily note",
        snippet: '/day',
        date: new Date(),
    }),
    () => ({
        detail: "Insert a link to today's daily note",
        snippet: '/today',
        date: new Date(),
    }),
    () => {
        const today = new Date();
        return {
            detail: "Insert a link to tomorrow's daily note",
            snippet: '/tomorrow',
            date: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1),
        };
    },
    () => {
        const today = new Date();
        return {
            detail: "Insert a link to yesterday's daily note",
            snippet: '/yesterday',
            date: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1),
        };
    },
];
const computedSnippets = [
    (days) => {
        const today = new Date();
        return {
            detail: `Insert a date ${days} day(s) from now`,
            snippet: `/+${days}d`,
            date: new Date(today.getFullYear(), today.getMonth(), today.getDate() + days),
        };
    },
    (weeks) => {
        const today = new Date();
        return {
            detail: `Insert a date ${weeks} week(s) from now`,
            snippet: `/+${weeks}w`,
            date: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7 * weeks),
        };
    },
    (months) => {
        const today = new Date();
        return {
            detail: `Insert a date ${months} month(s) from now`,
            snippet: `/+${months}m`,
            date: new Date(today.getFullYear(), today.getMonth() + months, today.getDate()),
        };
    },
    (years) => {
        const today = new Date();
        return {
            detail: `Insert a date ${years} year(s) from now`,
            snippet: `/+${years}y`,
            date: new Date(today.getFullYear() + years, today.getMonth(), today.getDate()),
        };
    },
];
const completions = {
    provideCompletionItems: (document, position, _token, _context) => {
        if (_context.triggerKind === vscode_1.CompletionTriggerKind.Invoke) {
            // if completion was triggered without trigger character then we return [] to fallback
            // to vscode word-based suggestions (see https://github.com/foambubble/foam/pull/417)
            return [];
        }
        const range = document.getWordRangeAtPosition(position, /\S+/);
        const completionItems = [
            ...snippetFactories.map(snippetFactory => snippetFactory()),
            ...generateDayOfWeekSnippets(),
        ].map(snippet => {
            const completionItem = createCompletionItem(snippet);
            completionItem.range = range;
            return completionItem;
        });
        return completionItems;
    },
};
exports.datesCompletionProvider = {
    provideCompletionItems: (document, position, _token, context) => {
        if (context.triggerKind === vscode_1.CompletionTriggerKind.Invoke) {
            // if completion was triggered without trigger character then we return [] to fallback
            // to vscode word-based suggestions (see https://github.com/foambubble/foam/pull/417)
            return [];
        }
        const range = document.getWordRangeAtPosition(position, /\S+/);
        const snippetString = document.getText(range);
        const matches = snippetString.match(/(\d+)/);
        const number = matches ? matches[0] : '1';
        const completionItems = computedSnippets.map(item => {
            const completionItem = createCompletionItem(item(parseInt(number)));
            completionItem.range = range;
            return completionItem;
        });
        // We still want the list to be treated as "incomplete", because the user may add another number
        return new vscode_1.CompletionList(completionItems, true);
    },
};
const datedNoteCommand = (date) => {
    if (foamNavigateOnSelect === 'navigateToNote') {
        return dated_notes_1.openDailyNoteFor(date);
    }
    if (foamNavigateOnSelect === 'createNote') {
        return dated_notes_1.createDailyNoteIfNotExists(foamConfig, dated_notes_1.getDailyNotePath(foamConfig, date), date);
    }
};
const feature = {
    activate: (context) => {
        context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.open-dated-note', date => datedNoteCommand(date)));
        vscode_1.languages.registerCompletionItemProvider('markdown', completions, '/');
        vscode_1.languages.registerCompletionItemProvider('markdown', exports.datesCompletionProvider, '/', '+');
    },
};
exports.default = feature;
//# sourceMappingURL=open-dated-note.js.map