return {
  {
    "folke/noice.nvim",
    opts = { presets = { lsp_doc_border = true } },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.component_separators = ""
      opts.options.section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" }
    end,
  },
}
