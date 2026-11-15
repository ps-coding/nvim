return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      on_colors = function(c)
        c.bg_statusline = c.none -- drop this line if you kept a solid statusline
        c.border_highlight = c.dark3
      end,
      on_highlights = function(hl, c)
        hl.BlinkCmpMenuSelection = { bg = c.bg_visual }
        local blend = require("tokyonight.util").blend
        for i = 1, 6 do
          hl["DashboardHeader" .. i] = { fg = blend(c.magenta, (i - 1) / 5, c.cyan) }
        end
      end,
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          function(self)
            local lines = vim.split(self.opts.preset.header:gsub("%s+$", ""), "\n")
            local text = {}
            for i, line in ipairs(lines) do
              text[i] = { line .. (i < #lines and "\n" or ""), hl = "DashboardHeader" .. math.min(i, 6) }
            end
            return { text = text, align = "center", padding = 2 }
          end,
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          { pane = 2, icon = "\u{f15b} ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = "\u{f07c} ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          scrollbar = false,
          draw = {
            columns = function(ctx)
              local cols = { { "kind_icon" }, { "label", "label_description", gap = 1 } }
              if ctx.mode ~= "cmdline" then
                cols[#cols + 1] = { "kind" }
              end
              return cols
            end,
          },
        },
        documentation = { window = { scrollbar = false } },
      },
    },
  },
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
