return {
  {
    "pwntester/octo.nvim",
    keys = {
      { "<leader>gS", false },
      {
        "<leader>gO",
        function()
          vim.ui.input({ prompt = "Octo search: " }, function(query)
            if query and vim.trim(query) ~= "" then
              vim.cmd("Octo search " .. query)
            end
          end)
        end,
        desc = "Search (Octo)",
      },
    },
  },
}
