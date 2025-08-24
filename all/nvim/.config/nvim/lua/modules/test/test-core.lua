local M = {}

local options = require("modules.test.test-options")

M.neotest = {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Everduin94/neotest-jest",
      "marilari88/neotest-vitest",
    },
    keys = options.neotest_keys,
    opts = options.neotest_opts,
  },
}

return M
