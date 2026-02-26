local M = {}

local options = require("modules.ai.ai-options")
local commands = require("modules.ai.ai-commands")

M.sidekick = {
  "folke/sidekick.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    nes = { enabled = false }, -- I strongly dislike NES
    cli = {
      prompts = require("modules.ai.ai-prompts"),
    },
  },
  keys = commands.sidekick_keys,
}

M.mcphub = {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest",
  config = function()
    require("mcphub").setup({
      auto_approve = true,
    })
  end,
}

M.copilot = {
  "zbirenbaum/copilot.lua",
  requires = {
    "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
  },
  cmd = "Copilot",
  event = "InsertEnter",
  filetypes = {
    [""] = false,
  },
  config = function()
    require("copilot").setup(options.copilot)
  end,
}

M.ninetynine = {
  "ThePrimeagen/99",
  config = options.ninetynine,
}

M.codecompanion = {
  "olimorris/codecompanion.nvim",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
  },
  config = function()
    require("codecompanion").setup({
      extensions = {
        -- Breaks even after updating everything.
        --
        -- mcphub = {
        --   callback = "mcphub.extensions.codecompanion",
        --   opts = {
        --     make_vars = true,
        --     make_slash_commands = true,
        --     show_result_in_chat = true,
        --   },
        -- },
      },
      prompt_library = options.prompt_library,
      strategies = options.strategies,
      adapters = options.adapters,
    })

    require("modules.ai.ai-commands")
  end,
}

M.img_clip = {
  "HakonHarnes/img-clip.nvim",
  opts = {
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  },
}

return M
