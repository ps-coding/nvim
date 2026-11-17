local buf = vim.api.nvim_get_current_buf()
local minipairs = require("mini.pairs")
local k = vim.keycode
local LEFT, RIGHT = k("<C-g>U<Left>"), k("<C-g>U<Right>")

vim.opt_local.wrap = true
vim.opt_local.spell = true

local function around_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return line:sub(1, col), line:sub(col + 1)
end

local function escaped(s)
  local bs = s:match("\\+$")
  return bs ~= nil and #bs % 2 == 1
end

local function in_zone(name)
  local ok, res = pcall(vim.fn["vimtex#syntax#" .. name])
  return ok and res == 1
end

local function map(lhs, rhs, desc)
  vim.keymap.set("i", lhs, rhs, { buffer = buf, expr = true, replace_keycodes = false, desc = desc })
end

local dollar = { action = "closeopen", pair = "$$", neigh_pattern = "[^\\].", register = { cr = false } }
minipairs.map_buf(buf, "i", "$", dollar)

map("$", function()
  local before, after = around_cursor()
  if after:sub(1, 1) ~= "$" and (in_zone("in_mathzone") or in_zone("in_comment")) then
    return "$"
  end
  if before:sub(-1) == "$" and after:sub(1, 1) == "$" and not before:match("%$%$$") then
    return k("$<CR>$<End><Esc>O")
  end
  return minipairs.closeopen(dollar.pair, dollar.neigh_pattern)
end, "LaTeX-aware $")

local latex_pairs = {
  { "\\left\\{", "\\right\\}" },
  { "\\left(", "\\right)" },
  { "\\left[", "\\right]" },
  { "\\left|", "\\right|" },
  { "\\(", "\\)" },
  { "\\[", "\\]" },
  { "\\{", "\\}" },
}

local function opened(text)
  for _, pair in ipairs(latex_pairs) do
    local open = pair[1]
    if text:sub(-#open) == open and not escaped(text:sub(1, -#open - 1)) then
      return pair[2]
    end
  end
end

local function closing(text, key)
  for _, pair in ipairs(latex_pairs) do
    local close = pair[2]
    if text:sub(1, #close) == close and close:sub(-1) == key then
      return close
    end
  end
end

for open_key, close_key in pairs({ ["("] = ")", ["["] = "]", ["{"] = "}", ["|"] = "|" }) do
  map(open_key, function()
    local before, after = around_cursor()
    local closer = opened(before .. open_key)
    if open_key == "|" and closing(after, "|") then
      return RIGHT:rep(#closing(after, "|"))
    elseif closer and not in_zone("in_comment") and not after:match("^[%w\\]") then
      return open_key .. closer .. LEFT:rep(#closer)
    elseif closer or open_key == "|" then
      return open_key
    end
    return minipairs.open(open_key .. close_key, "[^\\].")
  end, "LaTeX-aware " .. open_key)

  if close_key ~= "|" then
    map(close_key, function()
      local _, after = around_cursor()
      local closer = closing(after, close_key)
      if closer then
        return RIGHT:rep(#closer)
      end
      return minipairs.close(open_key .. close_key, "[^\\].")
    end, "LaTeX-aware " .. close_key)
  end
end

map("<BS>", function()
  local before, after = around_cursor()
  local closer = opened(before)
  if closer and after:sub(1, #closer) == closer then
    return k("<BS>") .. k("<Del>"):rep(#closer)
  end
  return minipairs.bs()
end, "LaTeX-aware backspace")

map("<CR>", function()
  local before, after = around_cursor()
  if opened(before) == "\\]" and after:sub(1, 2) == "\\]" then
    return k("<CR><C-o>O")
  end
  return minipairs.cr()
end, "LaTeX-aware enter")
