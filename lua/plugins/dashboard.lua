local function header(self)
  local lines = vim.split(self.opts.preset.header:gsub("%s+$", ""), "\n")
  local text = {}
  for i, line in ipairs(lines) do
    text[i] = { line .. (i < #lines and "\n" or ""), hl = "DashboardHeader" .. math.min(i, 6) }
  end
  return { text = text, align = "center", padding = 2 }
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
██████╗ ██████╗  █████╗ ███████╗██╗  ██╗ █████╗ ███╗   ███╗
██╔══██╗██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗████╗ ████║
██████╔╝██████╔╝███████║███████╗███████║███████║██╔████╔██║
██╔═══╝ ██╔══██╗██╔══██║╚════██║██╔══██║██╔══██║██║╚██╔╝██║
██║     ██║  ██║██║  ██║███████║██║  ██║██║  ██║██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
        ]],
        },
        sections = {
          header,
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          { pane = 2, icon = "\u{f15b} ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = "\u{f07c} ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        },
      },
    },
  },
}
