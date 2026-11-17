local function action(name)
  return function()
    require("orgmode").action(name)
  end
end

return {
  {
    "nvim-orgmode/orgmode",
    ft = "org",
    cmd = "Org",
    keys = {
      { "<leader>oa", action("agenda.prompt"), desc = "org agenda" },
      { "<leader>oc", action("capture.prompt"), desc = "org capture" },
    },
    opts = {
      org_agenda_files = "~/org/**/*",
      org_default_notes_file = "~/org/refile.org",
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>o", group = "overseer/org" },
      },
    },
  },
}
