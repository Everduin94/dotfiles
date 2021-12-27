local rxLikeMatches = {'query', 'store', 'effects', 'actions'}
local componentMatches = {'component', 'module'}

require("nvim-quick-switcher").setup({
  mappings = {
    {
      mapping = '<leader>mm',
      matchers = {
        { matches = {'cpp'}, suffix = 'h' },
        { matches = {'h'}, suffix = 'cpp' },
      }
    },
    {
      mapping = "<leader>oo",
      matchers = {
        { matches = rxLikeMatches, suffix = 'query.ts' },
        { matches = componentMatches, suffix = 'component.html'}
      }
    },
    {
      mapping = "<leader>oi",
      matchers = {
        { matches = rxLikeMatches, suffix = 'effects.ts' },
        { matches = componentMatches, suffix = 'component.scss'}
      }
    },
    {
      mapping = "<leader>ou",
      matchers = {
        { matches = rxLikeMatches, suffix = 'store.ts' },
        { matches = componentMatches, suffix = 'component.ts'}
      }
    },
    {
      mapping = "<leader>oy",
      matchers = {
        { matches = componentMatches, suffix = 'component.spec.ts'}
      }
    },
    {
      mapping = "<leader>oa",
      matchers = {
        { matches = rxLikeMatches, suffix = 'actions.ts'}
      }
    },
    {
      mapping = "<leader>op",
      matchers = {
        { matches = rxLikeMatches, suffix = 'module.ts'},
        { matches = componentMatches, suffix = 'module.ts'}
      }
    },
  }
})
