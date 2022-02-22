local git = require("git-util")

-- git.commit(git.buildCommitMessage("feat", "Athena", "Changes to Map", "Added multiple somethings to the map wow!"))

-- print(git.push('-f'))


local params = {...}

local table = {
  test = "one"
}

table["<leader>ff"] = { something = "else"}

print(table["<leader>ff"].something)

