local backdrop = "#35373c"

local function colors(c)
  local util = require("tokyonight.util")
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
end

local function highlights(hl, c)
  local blend = require("tokyonight.util").blend
  hl.BlinkCmpMenuSelection = { bg = c.bg_visual }
  for _, name in ipairs({ "BlinkCmpLabelDetail", "BlinkCmpLabelDescription", "BlinkCmpSource", "BlinkCmpKind" }) do
    hl[name] = { fg = c.fg_dark }
  end

  local readable = { [c.fg_gutter] = c.dark5, [c.terminal_black] = c.dark3 }
  for _, group in pairs(hl) do
    if type(group) == "table" and readable[group.fg] and (group.bg == nil or group.bg == c.none) then
      group.fg = readable[group.fg]
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
end

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      on_colors = colors,
      on_highlights = highlights,
    },
  },
}
