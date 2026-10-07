-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local group = vim.api.nvim_create_augroup("tex_dollar_pairs", { clear = true })

local function vimtex_query(fn)
  local ok, res = pcall(vim.fn["vimtex#syntax#" .. fn])
  return ok and res == 1
end

local function escaped(s)
  local bs = s:match("\\+$")
  return bs ~= nil and #bs % 2 == 1
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "tex", "plaintex" },
  desc = "Autoclose $ and $$ in LaTeX",
  callback = function(ev)
    vim.keymap.set("i", "$", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before, after = line:sub(1, col), line:sub(col + 1)
      local prev = vim.fn.matchstr(before, ".$")
      local nxt = vim.fn.matchstr(after, "^.")

      if escaped(before) then
        return "$"
      end
      if vimtex_query("in_comment") then
        return "$"
      end
      if prev == "$" and nxt == "$" and not before:match("%$%$$") then
        return "$<CR>$<End><Esc>O"
      end
      if nxt == "$" then
        return "<C-g>U<Right>"
      end
      if vimtex_query("in_mathzone") then
        return "$"
      end
      if vim.fn.match(nxt, [[\k\|\\]]) >= 0 then
        return "$"
      end
      return "$$<C-g>U<Left>"
    end, { buffer = ev.buf, expr = true, desc = "Autoclose $ / $$" })

    vim.keymap.set("i", "<BS>", function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_get_current_line()
      local before, after = line:sub(1, col), line:sub(col + 1)

      if before:sub(-1) == "$" and after:sub(1, 1) == "$" and not escaped(before:sub(1, -2)) then
        return vim.keycode("<BS><Del>")
      end

      if before:match("^%s*$") and after == "" then
        local above = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
        local below = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
        if
          above
          and below
          and above:match("%$%$$")
          and not escaped(above:sub(1, -3))
          and below:match("^%s*%$%$%s*$")
        then
          local ws = #below:match("^%s*")
          return vim.keycode("<C-u><BS><BS>" .. string.rep("<Del>", ws + 2))
        end
      end

      local ok, mp = pcall(require, "mini.pairs")
      return ok and mp.bs() or vim.keycode("<BS>")
    end, { buffer = ev.buf, expr = true, replace_keycodes = false, desc = "Delete $ pairs" })
  end,
})
