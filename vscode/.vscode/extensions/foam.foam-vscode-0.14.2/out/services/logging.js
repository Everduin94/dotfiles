"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.exposeLogger = exports.VsCodeOutputLogger = void 0;
const vscode_1 = require("vscode");
const foam_core_1 = require("foam-core");
const settings_1 = require("../settings");
class VsCodeOutputLogger extends foam_core_1.BaseLogger {
    constructor() {
        super(settings_1.getFoamLoggerLevel());
        this.channel = vscode_1.window.createOutputChannel('Foam');
        this.channel.appendLine('Foam Logging: ' + settings_1.getFoamLoggerLevel());
    }
    log(lvl, msg, ...extra) {
        if (msg) {
            this.channel.appendLine(`[${lvl} - ${new Date().toLocaleTimeString()}] ${msg}`);
        }
        extra === null || extra === void 0 ? void 0 : extra.forEach(param => {
            if (param === null || param === void 0 ? void 0 : param.stack) {
                this.channel.appendLine(JSON.stringify(param.stack, null, 2));
            }
            else {
                this.channel.appendLine(JSON.stringify(param, null, 2));
            }
        });
    }
    show() {
        this.channel.show();
    }
    dispose() {
        this.channel.dispose();
    }
}
exports.VsCodeOutputLogger = VsCodeOutputLogger;
exports.exposeLogger = (context, logger) => {
    context.subscriptions.push(vscode_1.commands.registerCommand('foam-vscode.set-log-level', async () => {
        const items = ['debug', 'info', 'warn', 'error'];
        const level = await vscode_1.window.showQuickPick(items.map(item => ({
            label: item,
            description: item === logger.getLevel() && 'Current',
        })));
        logger.setLevel(level.label);
    }));
};
//# sourceMappingURL=logging.js.map