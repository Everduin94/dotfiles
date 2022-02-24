require("harpoon").setup({
    global_settings = {
      enter_on_sendcmd = true,
    },
    projects = {
        ["$HOME/Documents/dev/monobased/apps/full-metal-template"] = {
            term = {
                cmds = {
                    "ls -a",
                }
            }
        }
    }
})
