-- Test
local util = require("util")
util.printMsg("hello there")

local command = "git rev-parse --abbrev-ref HEAD"
local handle = io.popen(command);
local result = handle:read("*a"); -- *a reads whole file
handle:close();


local params = {...}
print(params[1])


print(result);
