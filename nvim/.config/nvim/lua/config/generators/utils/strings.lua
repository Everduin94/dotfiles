local M = {}

function M.capitalize(str)
  return str:gsub("(%a)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

function M.to_pascal_case(name)
  return name
    :gsub("-(%l)", function(c)
      return c:upper()
    end) -- Capitalize letters after '-'
    :gsub("^%l", string.upper) -- Capitalize first letter
end

function M.to_snake_case(name)
  return name:gsub("-", "_")
end

return M
