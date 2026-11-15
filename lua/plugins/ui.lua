return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      on_colors = function(c)
        local util = require("tokyonight.util")
        local backdrop = "#35373c"
        c.bg, util.bg = backdrop, backdrop

        c.comment = util.blend(c.fg_dark, 0.70, backdrop)
        c.dark3 = util.blend(c.fg_dark, 0.50, backdrop)
        c.terminal.black_bright = c.dark3
        c.git.ignore = c.dark3
        c.git.delete = util.blend(c.red1, 0.80, backdrop)

        c.bg_highlight = util.blend(c.blue, 0.14, backdrop)
        c.bg_visual = util.blend(c.blue0, 0.80, backdrop)
        c.diff = {
          add = util.blend(c.green2, 0.25, backdrop),
          delete = util.blend(c.red1, 0.25, backdrop),
          change = util.blend(c.blue7, 0.40, backdrop),
          text = c.blue7,
        }
        c.border = c.dark3
        c.border_highlight = c.dark3
        c.bg_statusline = c.none
      end,
      on_highlights = function(hl, c)
        local blend = require("tokyonight.util").blend
        hl.BlinkCmpMenuSelection = { bg = c.bg_visual }

        local lift = { [c.fg_gutter] = c.dark5, [c.terminal_black] = c.dark3 }
        for _, group in pairs(hl) do
          if type(group) == "table" and lift[group.fg] and (group.bg == nil or group.bg == c.none) then
            group.fg = lift[group.fg]
          end
        end
        for _, name in ipairs({ "SnacksIndent", "SnacksIndentBlank", "SnacksPickerTree", "Whitespace", "AerialGuide" }) do
          hl[name] = { fg = blend(c.fg_dark, 0.28, c.bg) }
        end
        local reference = { bg = blend(c.dark5, 0.35, c.bg) }
        hl.LspReferenceText, hl.LspReferenceRead, hl.LspReferenceWrite = reference, reference, reference
        hl.LspInlayHint = { fg = c.dark3, italic = true }
        for name, color in pairs({
          Add = c.git.add,
          Untracked = c.git.add,
          Change = c.git.change,
          Changedelete = c.git.change,
          Delete = c.git.delete,
          Topdelete = c.git.delete,
        }) do
          hl["GitSignsStaged" .. name] = { fg = blend(color, 0.55, c.bg) }
        end

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
        documentation = {
          window = { scrollbar = false },
          draw = function(opts)
            opts.default_implementation()
            local text = table.concat(vim.api.nvim_buf_get_lines(opts.window:get_buf(), 0, -1, false), "\n")
            text = text:gsub("</?text>", ""):gsub("```%w*", "")
            if not text:find("%S") then
              vim.schedule(function()
                require("blink.cmp").hide_documentation()
              end)
            end
          end,
        },
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
