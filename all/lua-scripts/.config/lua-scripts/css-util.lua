
local M = {}

function M.updateCssProps(fileName)
  local home = os.getenv('HOME')
  local f = assert(io.open(home .. '/dev/cx-cloud-ui/libs/shared/multi/ui/figure-8/src/scss/figure-8/tokens/_core.scss', "r"))
  local t = f:read("*all")
  f:close()

  local lines = {}
  for line in io.lines(home ..  '/dev/cx-cloud-ui/libs/shared/multi/ui/figure-8/src/scss/figure-8/tokens/_core.scss') do
    lines[#lines + 1] = line
  end

  -- empty space by dash dash by decimal|letter|dash by colon by empty space by hashtag|decimal|letter|parens-left|parens-right|dash 
  -- In many cases, I use % as a dereference, just to be explicit.
  -- Sometimes I also expect I would need a * or + and I don't, adding it doesn't seem to break anything.

  -- ipairs only works with index based props.
  local pattern =  "%s(--[%d|%a|-]+):%s([#|%d|%a|%)|%(|%-|%%]+)";

  local props = {}
  for key, value in pairs(lines) do
    local k, v = string.match(value,pattern)

    if v then
      props[k] = v;
    end
  end

  for prop, value in pairs(props) do
    local nestedProp = string.match(value, 'var%(([%a|%-|%d]+)%)')
    if nestedProp and props[nestedProp] then
      props[prop] = props[nestedProp]
    end
  end

  local colors = {}
  for prop, value in pairs(props) do
    local colorPattern = string.match(prop, '(--core%-color+%-+[%a|%d|%-]*)')
    if colorPattern then
      colors[value] = 'var('..prop..')'
    end
  end

  local spacing = {}
  for prop, value in pairs(props) do
    local spacingPattern = string.match(prop, '(--core%-spacing+%-+[%a|%d|%-]*)')
    if spacingPattern then
      spacing[value] = 'var('..prop..')'
    end
  end

  local fontSize = {}
  for prop, value in pairs(props) do
    local fontSizePattern = string.match(prop, '(--core%-font%-size+%-+[%a|%d|%-]*)')
    if fontSizePattern then
      fontSize[value] = 'var('..prop..')'
    end
  end

  local border_radius = {}
  for prop, value in pairs(props) do
    local radiusPattern = string.match(prop, '(--core%-radius%-[%d]+)')
    if radiusPattern then
      border_radius[value] = 'var('..prop..')'
    end
  end

  -- loop the lines, modify the line, edit the line if you have a find, otherwise return the exact same line.
  local updatedLines = {}
  for line in io.lines(fileName) do
    local value = string.match(line, '%#[%d|%a]+')
      local isMargin = string.match(line, 'margin%-*[%a]*:')
      local isPadding = string.match(line, 'padding%-*[%a]*:')
      local isFont = string.match(line, 'font%-*[%a]*:')
      local isRadius = string.match(line, 'border%-radius:')
      if isMargin or isPadding then
        local match = string.gsub(line, '%d+px', function (value)
          return spacing[value]
        end)
        table.insert(updatedLines, match)
      elseif isFont then
        local match = string.gsub(line, '%d+px', function (value)
          return fontSize[value]
        end)
        table.insert(updatedLines, match)
      elseif isRadius then
        local match = string.gsub(line, '%d+[px|%%]+', function (value)
          return border_radius[value]
        end)
        table.insert(updatedLines, match)
    elseif value and colors[value] then
      local update = string.gsub(line, '%#[%d|%a]+', colors[value])
      table.insert(updatedLines, update)
    else
      table.insert(updatedLines, line)
    end
  end

  local out = io.open(fileName, 'w')
  for _, line in ipairs(updatedLines) do
      out:write(line .. '\n')
  end
  out:close()

end


return M
