-- TODO: Move me to modules
local M = {
  {
    fn = function()
      vim.cmd("GenerateSvelteFeatureFolder")
    end,
    desc = "My example generator",
    icon = { icon = "󰈸", color = "green" },
    key = "<leader>mg1",
  },
}
return M
