-- IDK yet
local flash = require("flash")

vim.api.nvim_set_hl(0, 'FlashBackdrop', { fg = "#ffffff", bg = "#333333" })

flash.setup({
	jump = {
		nohlsearch = true,
	},
	modes = {
		search = {
			enabled = true,
			jump = { nohlsearch = false },
		},
	},
})

vim.keymap.set({ "n", "o", "x" }, "s", function()
	flash.jump({
		jump = {
			nohlsearch = false,
		},
	})
end, { desc = "Flash" })


vim.keymap.set({ "o" }, "r", function()
	flash.jump({
		jump = {
			nohlsearch = false,
		},
	})
end, { desc = "Flash" })
