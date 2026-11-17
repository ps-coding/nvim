local buf = vim.api.nvim_get_current_buf()

vim.opt_local.wrap = true
vim.opt_local.spell = true

require("latex.pairs").attach(buf)
require("latex.snippets").load_on_insert(buf)
