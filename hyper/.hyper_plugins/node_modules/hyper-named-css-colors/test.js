const test = require('tape');
const { decorateConfig } = require('./index');

test('default config has correct border and cursor color', t => {
	const config = decorateConfig({});

	t.plan(3);
	t.equal(config.backgroundColor, '#1E1E1E');
	t.equal(config.borderColor, 'transparent');
	t.equal(config.cursorColor, 'tomato');
});

test('user config can overwrite border and cursor color', t => {
	const config = decorateConfig({
		backgroundColor: '#123',
		borderColor: '#123',
		cursorColor: '#123',
	});

	t.plan(3);
	t.equal(config.backgroundColor, '#123');
	t.equal(config.borderColor, '#123');
	t.equal(config.cursorColor, '#123');
});
