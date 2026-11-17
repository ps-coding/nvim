local function remove_loading_label(placement)
  local ns = vim.api.nvim_get_namespaces()["snacks.image"]
  local marks = ns and vim.api.nvim_buf_get_extmarks(placement.buf, ns, 0, -1, { details = true }) or {}
  for _, mark in ipairs(marks) do
    local text = mark[4].virt_text
    if text and text[#text][2] == "SnacksImageLoading" then
      vim.api.nvim_buf_del_extmark(placement.buf, ns, mark[1])
    end
  end
end

local function clear_loading_labels_on_pdf_pages()
  local ok, placement = pcall(require, "snacks.image.placement")
  if not ok then
    return
  end
  local new = placement.new
  placement.new = function(buf, src, opts)
    if vim.api.nvim_buf_get_name(buf):lower():match("%.pdf$") then
      opts = opts or {}
      local on_update = opts.on_update
      opts.on_update = function(page)
        remove_loading_label(page)
        if on_update then
          on_update(page)
        end
      end
    end
    return new(buf, src, opts)
  end
end

return {
  {
    "r-pletnev/pdfreader.nvim",
    event = "BufEnter *.pdf",
    cmd = "PDFReader",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("pdfreader").setup()
      clear_loading_labels_on_pdf_pages()
    end,
  },
}
