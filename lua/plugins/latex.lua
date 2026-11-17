local function is_tex(ctx)
  return vim.bo[ctx.bufnr].filetype == "tex"
end

return {
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        accept = { auto_brackets = { blocked_filetypes = { "tex" } } },
      },
      sources = {
        providers = {
          lsp = {
            override = {
              get_completions = function(source, ctx, callback)
                if is_tex(ctx) then
                  return require("latex.completion").request_fresh(source, ctx, callback)
                end
                return source:get_completions(ctx, callback)
              end,
            },
          },
        },
      },
    },
  },
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    lazy = true,
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    opts = { use_treesitter = false, allow_on_markdown = false },
    config = function(_, opts)
      require("latex.snippets").setup(opts)
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    opts = { enable_autosnippets = true },
  },
}
