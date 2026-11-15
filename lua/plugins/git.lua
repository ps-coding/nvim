return {
  {
    "pwntester/octo.nvim",
    keys = {
      { "<leader>gS", false },
      {
        "<leader>gO",
        function()
          -- with the snacks picker, Octo's search needs the query up front; an empty one times out
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
