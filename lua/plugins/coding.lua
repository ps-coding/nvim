return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { current_line = false },
        virtual_lines = { current_line = true },
      },
      codelens = { enabled = true },
    },
  },
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    ft = "tex",
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    opts = { use_treesitter = false, allow_on_markdown = false },
  },
  { "L3MON4D3/LuaSnip", opts = { enable_autosnippets = true } },
}
