return {
  ninetynine = function()
    local _99 = require("99")
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)
    _99.setup({
      -- provider = _99.ClaudeCodeProvider,  -- default: OpenCodeProvider
      provider = _99.OpenCodeProvider,
      model = "github-copilot/gpt-5.2-codex",
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },

      --- Completions: #rules and @files in the prompt buffer
      completion = {
        -- custom_rules = {
        --   "scratch/custom_rules/",
        -- },

        --- Configure @file completion (all fields optional, sensible defaults)
        files = {
          -- enabled = true,
          -- max_file_size = 102400,     -- bytes, skip files larger than this
          -- max_files = 5000,            -- cap on total discovered files
          -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
        },
        -- source = "cmp",
      },

      md_files = {
        "AGENT.md",
      },
    })

    vim.keymap.set("v", "<leader>9v", function()
      _99.visual()
    end)

    vim.keymap.set("v", "<leader>9s", function()
      _99.stop_all_requests()
    end)
  end,
  copilot = {

    suggestion = {
      enabled = true,
      auto_trigger = true, -- This
      hide_during_completion = false,
      debounce = 200,
      trigger_on_accept = true,
      keymap = {
        -- Set all to false. Let manual keymap handle:
        -- https://github.com/zbirenbaum/copilot.lua/issues/577
        accept = false, -- this
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-e>",
      },
    },
  },
  mcphub = {
    callback = "mcphub.extensions.codecompanion",
    opts = {
      -- MCP Tools
      make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
      show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
      add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
      show_result_in_chat = true, -- Show tool results directly in chat buffer
      format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
      -- MCP Resources
      make_vars = true, -- Convert MCP resources to #variables for prompts
      -- MCP Prompts
      make_slash_commands = true, -- Add MCP prompts as /slash commands
    },
  },

  prompt_library = {
    ["Copilot Rules"] = {
      strategy = "chat",
      description = "Start a prompt with ai rules",
      opts = {
        index = 11,
        is_slash_cmd = false,
        auto_submit = false,
        short_name = "rules",
      },
      context = {
        {
          type = "file",
          path = {
            -- ".github/copilot-instructions.md",
            "/Users/erik/dotfiles/all/rules/general.md",
          },
        },
      },
      prompts = {
        {
          role = "user",
          content = [[
            I have provided a rules file, general.md.
            Read it.
            Follow the rules to the best of your ability when thinking and generating responses.
          ]],
        },
      },
    },
  },

  strategies = {
    chat = {
      adapter = {
        name = "copilot",
        model = "claude-sonnet-4.5",
      },

      variables = {
        ["rules"] = {
          callback = "config.utils.rules-variable",
          description = "The general AI rules",
          opts = {
            contains_code = false,
          },
        },
      },
    },
    inline = {
      adapter = {
        name = "copilot",
        model = "claude-sonnet-4.5",
      },
      -- adapter = "ollama",
    },
    cmd = {
      adapter = {
        name = "copilot",
        model = "claude-sonnet-4.5",
      },
      -- adapter = "ollama",
    },
  },

  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        name = "Ollama Arch",
        env = {
          url = "http://localhost:11435",
        },
        schema = {
          model = {
            default = "gpt-oss:20b",
          },
        },
      })
    end,
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key = "cmd:cat ~/.secrets/.anthropic",
        },
      })
    end,
  },
}
