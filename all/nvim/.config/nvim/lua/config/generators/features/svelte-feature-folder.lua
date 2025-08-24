local sv_templates = require("config/generators/templates/svelte-templates")
local string_utils = require("config/generators/utils/strings")
vim.api.nvim_create_user_command("GenerateSvelteFeatureFolder", function()
  vim.ui.input({ prompt = "Enter base folder name (default: notebooks): " }, function(input)
    local base_name = input

    local base_dir = "./src/lib/v2/features/" .. base_name
    local class_name = string_utils.to_pascal_case(base_name)
    local snake_name = string_utils.to_snake_case(base_name)

    local files = {
      ["state/" .. base_name .. "-state.svelte.ts"] = sv_templates.svelte_class(snake_name, class_name),
      ["components/" .. class_name .. "Entry.svelte"] = sv_templates.svelte_entry_point(
        base_name,
        snake_name,
        class_name
      ),
      ["utils/" .. base_name .. "-utils.ts"] = { template = [[ ]] },
      ["docs/" .. base_name .. "-docs.md"] = sv_templates.svelte_docs(base_name, snake_name, class_name),
    }

    vim.fn.mkdir(base_dir, "p")

    for relative_path, data in pairs(files) do
      local full_path = base_dir .. "/" .. relative_path
      local folder = full_path:match("(.*/)")
      vim.fn.mkdir(folder, "p")

      local file = io.open(full_path, "w")
      if file and data.template then
        file:write(data.template)
        file:close()
        print("Created " .. full_path)
      else
        print("Error: Could not create " .. full_path)
      end
    end

    print("Feature created successfully in " .. base_dir .. " 🚀")
  end)
end, {})

-- TODO:
-- Extract templates
-- Extract utilities
-- It's okay to keep it specific, this is the generate feature command. But, you may end up creating multiple of these. Make sure that isn't a maintenance nightmare.
