local git = require("git-util")

-- git.commit(git.buildCommitMessage("feat", "Athena", "Changes to Map", "Added multiple somethings to the map wow!"))

-- print(git.push('-f'))


local params = {...}
print(params[1])


print(package.path)
