return {
  {
    "Julian/lean.nvim",
    init = function()
      vim.g.lean_config = LazyVim.opts("lean.nvim")
    end,
    config = function(_, opts)
      local lean = require("lean")
      if lean.setup then
        lean.setup(opts)
      end
    end,
  },
}
