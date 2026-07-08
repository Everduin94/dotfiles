return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    {
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      "selene.toml",
      "selene.yml",
    },
    ".git",
  },
  on_init = function(client)
    local workspace = client.workspace_folders and client.workspace_folders[1]
    local path = workspace and workspace.name

    if path and path ~= vim.fn.stdpath("config") then
      if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    })
  end,
  settings = {
    Lua = {
      hint = { enable = true },
      telemetry = { enable = false },
    },
  },
}
