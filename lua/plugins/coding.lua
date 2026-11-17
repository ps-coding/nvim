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
    config = function(_, opts)
      local variables = {}
      local names = "alpha beta gamma delta epsilon varepsilon zeta eta theta vartheta iota kappa lambda mu nu xi "
        .. "pi varpi rho varrho sigma varsigma tau upsilon phi varphi chi psi omega ell "
        .. "Gamma Delta Theta Lambda Xi Pi Sigma Upsilon Phi Psi Omega"
      for name in names:gmatch("%a+") do
        variables[name] = true
      end

      local ok, wrA = pcall(require, "luasnip-latex-snippets.math_wrA")
      if ok then
        local retrieve = wrA.retrieve
        wrA.retrieve = function(is_math)
          return retrieve(function(line)
            local slashes, command = line:match("(\\+)(%a+)%d$")
            local after_command = slashes ~= nil and #slashes % 2 == 1
            return not (after_command and not variables[command]) and is_math()
          end)
        end
      end

      require("luasnip-latex-snippets").setup(opts)
    end,
  },
  { "L3MON4D3/LuaSnip", opts = { enable_autosnippets = true } },
}
