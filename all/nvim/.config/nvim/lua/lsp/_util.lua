local M = {}

function M.prefer_local_executable(root_dir, bin)
  if root_dir and root_dir ~= "" then
    local local_bin = vim.fs.joinpath(root_dir, "node_modules", ".bin", bin)
    if vim.fn.executable(local_bin) == 1 then
      return local_bin
    end
  end

  return bin
end

function M.node_command(bin)
  return function(dispatchers, config)
    local cmd = M.prefer_local_executable(config and config.root_dir, bin)
    return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
  end
end

function M.read_json(path)
  if not vim.uv.fs_stat(path) then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local ok_json, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_json then
    return nil
  end

  return decoded
end

function M.find_package_with_dependency(bufnr, dependencies)
  if type(dependencies) == "string" then
    dependencies = { dependencies }
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end

  local package_files = vim.fs.find("package.json", {
    path = vim.fs.dirname(name),
    upward = true,
    type = "file",
  })

  for _, package_file in ipairs(package_files) do
    local package_json = M.read_json(package_file)
    local deps = vim.tbl_extend(
      "keep",
      (package_json and package_json.dependencies) or {},
      (package_json and package_json.devDependencies) or {},
      (package_json and package_json.peerDependencies) or {},
      (package_json and package_json.optionalDependencies) or {}
    )

    for _, dependency in ipairs(dependencies) do
      if deps[dependency] then
        return vim.fs.dirname(package_file)
      end
    end
  end
end

return M
