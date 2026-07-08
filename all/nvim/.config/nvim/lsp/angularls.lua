local util = require("lsp._util")

local function add_unique(list, seen, value)
  if value and value ~= "" and not seen[value] and vim.uv.fs_stat(value) then
    seen[value] = true
    table.insert(list, value)
  end
end

local function collect_node_modules(root_dir)
  local paths = {}
  local seen = {}

  add_unique(paths, seen, vim.fs.joinpath(root_dir, "node_modules"))

  local ngserver = vim.fn.exepath("ngserver")
  if ngserver ~= "" then
    local realpath = vim.uv.fs_realpath(ngserver) or ngserver
    add_unique(paths, seen, vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(realpath), "../../..")))
  end

  return paths
end

local function get_angular_core_version(root_dir)
  local package_json = util.read_json(vim.fs.joinpath(root_dir, "package.json")) or {}
  local dependencies = vim.tbl_extend(
    "keep",
    package_json.dependencies or {},
    package_json.devDependencies or {}
  )

  local version = dependencies["@angular/core"] or ""
  return version:match("%d+%.%d+%.%d+") or ""
end

return {
  workspace_required = true,
  cmd = function(dispatchers, config)
    local root_dir = (config and config.root_dir) or vim.fn.getcwd()
    local node_paths = collect_node_modules(root_dir)
    local ng_probe_paths = {}

    for _, path in ipairs(node_paths) do
      table.insert(ng_probe_paths, vim.fs.joinpath(path, "@angular/language-server", "node_modules"))
    end

    local cmd = {
      util.prefer_local_executable(root_dir, "ngserver"),
      "--stdio",
      "--tsProbeLocations",
      table.concat(node_paths, ","),
      "--ngProbeLocations",
      table.concat(ng_probe_paths, ","),
      "--angularCoreVersion",
      get_angular_core_version(root_dir),
    }

    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { "typescript", "html", "typescriptreact", "htmlangular" },
  root_markers = { "angular.json", "nx.json" },
}
