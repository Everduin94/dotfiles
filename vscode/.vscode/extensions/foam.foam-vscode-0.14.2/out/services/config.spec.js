"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const document_decorator_1 = require("../features/document-decorator");
const config_1 = require("./config");
describe('configuration service', () => {
    it('should get the configuraiton option', async () => {
        await config_1.updateFoamVsCodeConfig(document_decorator_1.CONFIG_KEY, true);
        expect(config_1.getFoamVsCodeConfig(document_decorator_1.CONFIG_KEY)).toBeTruthy();
    });
    it('should monitor changes in configuration', async () => {
        await config_1.updateFoamVsCodeConfig(document_decorator_1.CONFIG_KEY, true);
        const getter = config_1.monitorFoamVsCodeConfig(document_decorator_1.CONFIG_KEY);
        expect(getter()).toBeTruthy();
        await config_1.updateFoamVsCodeConfig(document_decorator_1.CONFIG_KEY, false);
        expect(getter()).toBeFalsy();
        getter.dispose();
    });
});
//# sourceMappingURL=config.spec.js.map