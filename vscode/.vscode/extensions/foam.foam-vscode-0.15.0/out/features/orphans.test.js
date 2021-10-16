"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const foam_core_1 = require("foam-core");
const test_utils_1 = require("../test/test-utils");
const orphans_1 = require("./orphans");
const orphanA = test_utils_1.createTestNote({
    uri: '/path/orphan-a.md',
    title: 'Orphan A',
});
const nonOrphan1 = test_utils_1.createTestNote({
    uri: '/path/non-orphan-1.md',
});
const nonOrphan2 = test_utils_1.createTestNote({
    uri: '/path/non-orphan-2.md',
    links: [{ slug: 'non-orphan-1' }],
});
const workspace = test_utils_1.createTestWorkspace()
    .set(orphanA)
    .set(nonOrphan1)
    .set(nonOrphan2);
const graph = foam_core_1.FoamGraph.fromWorkspace(workspace);
describe('isOrphan', () => {
    it('should return true when a note with no connections is provided', () => {
        expect(orphans_1.isOrphan(orphanA.uri, graph)).toBeTruthy();
    });
    it('should return false when a note with connections is provided', () => {
        expect(orphans_1.isOrphan(nonOrphan1.uri, graph)).toBeFalsy();
    });
});
//# sourceMappingURL=orphans.test.js.map