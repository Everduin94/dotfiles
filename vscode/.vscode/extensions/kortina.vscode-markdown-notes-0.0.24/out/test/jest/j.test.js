require('jest');
const foo = () => 1;
test('foo', () => {
  debugger;
  expect(foo()).toBe(1);
});
