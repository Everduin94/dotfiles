local opts = { noremap = true, silent = true }

local function find(file_regex, opts)
  return function() require('nvim-quick-switcher').find(file_regex, opts) end
end

local function inline_ts_switch(scheme, opts)
  return function() require('nvim-quick-switcher').inline_ts_switch(scheme, opts) end
end

local function find_by_fn(fn, opts)
  return function() require('nvim-quick-switcher').find_by_fn(fn, opts) end
end

-- Styles
vim.keymap.set("n", "<leader>oi", find('.+css|.+scss|.+sass', { regex = true, prefix='full' }), opts)

-- Types
vim.keymap.set("n", "<leader>orm", find('.+model.ts|.+models.ts|.+types.ts', { regex = true }), opts)

-- Util
vim.keymap.set("n", "<leader>ol", find('*util.*', { prefix = 'short' }), opts)

-- Tests
vim.keymap.set("n", "<leader>ot", find('.+test|.+spec', { regex = true, prefix='full' }), opts)


vim.api.nvim_create_autocmd({'UIEnter'}, {
    callback = function(event)
      local is_angular = next(vim.fs.find({ "angular.json", "nx.json" }, { upward = true }))
      local is_svelte = next(vim.fs.find({ "svelte.config.js", "svelte.config.ts" }, { upward = true }))

      -- Angular
      if is_angular then
        print('Angular')
        vim.keymap.set("n", "<leader>oo", find('.component.html'), opts)
        vim.keymap.set("n", "<leader>ou", find('.component.ts'), opts)
        vim.keymap.set("n", "<leader>op", find('.module.ts'), opts)
        vim.keymap.set("n", "<leader>oy", find('.service.ts'), opts)
      end

      -- SvelteKit
      if is_svelte then
        print('Svelte')
        vim.keymap.set("n", "<leader>oo", find('*page.svelte', { maxdepth = 1, ignore_prefix = true }), opts)
        vim.keymap.set("n", "<leader>ou", find('.*page.server(.+js|.+ts)|.*page(.+js|.+ts)', { maxdepth = 1, regex = true, ignore_prefix = true }), opts)
        vim.keymap.set("n", "<leader>op", find('*layout.svelte', { maxdepth = 1, ignore_prefix = true }), opts)

         -- Inline TS
        vim.keymap.set("n", "<leader>oj", inline_ts_switch('svelte', '(script_element (end_tag) @capture)'), opts)
        vim.keymap.set("n", "<leader>ok", inline_ts_switch('svelte', '(style_element (start_tag) @capture)'), opts)
      end
    end
})


-- Redux-like
vim.keymap.set("n", "<leader>ore", find('*effects.ts'), opts)
vim.keymap.set("n", "<leader>ora", find('*actions.ts'), opts)
vim.keymap.set("n", "<leader>orw", find('*store.ts'), opts)
vim.keymap.set("n", "<leader>orf", find('*facade.ts'), opts)
vim.keymap.set("n", "<leader>ors", find('.+query.ts|.+selectors.ts|.+selector.ts', { regex = true }), opts)
vim.keymap.set("n", "<leader>orr", find('.+reducer.ts|.+repository.ts', { regex = true }), opts)

-- Java J-Unit (Advanced Example)
local find_test_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('src', 'test') .. '/' .. file_name .. '*';
  return result;
end

local find_src_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('test', 'src') .. '/' .. file_name .. '*';
  return result;
end

vim.keymap.set("n", "<leader>ojj", find_by_fn(find_test_fn), opts)
vim.keymap.set("n", "<leader>ojk", find_by_fn(find_src_fn), opts)
