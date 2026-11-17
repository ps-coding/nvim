local M = {}

local key = vim.keycode
local LEFT, RIGHT = key("<C-g>U<Left>"), key("<C-g>U<Right>")
local BACKSPACE, DELETE = key("<BS>"), key("<Del>")

local sizes = {
  left = "right",
  bigl = "bigr",
  Bigl = "Bigr",
  biggl = "biggr",
  Biggl = "Biggr",
  big = "big",
  Big = "Big",
  bigg = "bigg",
  Bigg = "Bigg",
}

local sized_brackets = {
  ["("] = ")",
  ["["] = "]",
  ["|"] = "|",
  ["\\{"] = "\\}",
  ["\\|"] = "\\|",
}

local brackets = { ["("] = ")", ["["] = "]", ["{"] = "}", ["|"] = "|" }

local verbatim_zones = "tex\\%(Verb\\|Lst\\|Minted\\|Url\\|File\\|Tikz\\|Pythontex\\|Luacode\\)"

local delimiters = { { "\\(", "\\)" }, { "\\[", "\\]" }, { "\\{", "\\}" } }
for open_size, close_size in pairs(sizes) do
  for open, close in pairs(sized_brackets) do
    delimiters[#delimiters + 1] = { "\\" .. open_size .. open, "\\" .. close_size .. close }
  end
end
table.sort(delimiters, function(a, b)
  if #a[1] ~= #b[1] then
    return #a[1] > #b[1]
  end
  return a[1] < b[1]
end)

local function around_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return line:sub(1, col), line:sub(col + 1)
end

local function escaped(text)
  local backslashes = text:match("\\+$")
  return backslashes ~= nil and #backslashes % 2 == 1
end

local function in_zone(query, ...)
  local ok, result = pcall(vim.fn["vimtex#syntax#" .. query], ...)
  return ok and result == 1
end

local function closer_for(text)
  for _, delimiter in ipairs(delimiters) do
    local open = delimiter[1]
    if text:sub(-#open) == open and not escaped(text:sub(1, -#open - 1)) then
      return delimiter[2]
    end
  end
end

local function closer_at(text, last_char)
  for _, delimiter in ipairs(delimiters) do
    local close = delimiter[2]
    if text:sub(1, #close) == close and close:sub(-1) == last_char then
      return close
    end
  end
end

local function starts_with_closer(text)
  for _, delimiter in ipairs(delimiters) do
    if text:sub(1, #delimiter[2]) == delimiter[2] then
      return true
    end
  end
  return false
end

local function precedes_content(after)
  if after:sub(1, 1) == "\\" then
    return not starts_with_closer(after)
  end
  return after:match("^%w") ~= nil
end

local function pass_closer(before, after, last_char)
  local closer = closer_at(after, last_char)
  if not closer then
    return
  end
  local typed = closer:sub(1, -2)
  if before:sub(-#typed) == typed and not escaped(before:sub(1, -#typed - 1)) then
    return last_char .. DELETE:rep(#closer)
  end
  return RIGHT:rep(#closer)
end

local function open_bracket(open, close)
  local minipairs = require("mini.pairs")
  local before, after = around_cursor()
  local closer = closer_for(before .. open)
  local passed = open == close and pass_closer(before, after, open)
  if passed then
    return passed
  end
  if closer and not in_zone("in_comment") and not precedes_content(after) then
    return open .. closer .. LEFT:rep(#closer)
  end
  if closer or open == close then
    return open
  end
  return minipairs.open(open .. close, "[^\\].")
end

local function close_bracket(open, close)
  local before, after = around_cursor()
  return pass_closer(before, after, close) or require("mini.pairs").close(open .. close, "[^\\].")
end

local function dollar()
  local before, after = around_cursor()
  if after:sub(1, 1) ~= "$" and (in_zone("in_mathzone") or in_zone("in_comment")) then
    return "$"
  end
  if before:sub(-1) == "$" and after:sub(1, 1) == "$" and not before:match("%$%$$") then
    return key("$<CR>$<End><Esc>O")
  end
  return require("mini.pairs").closeopen("$$", "[^\\].")
end

local function keeps_straight_quote(before)
  return escaped(before)
    or before:match("\\texttt{[^}]*$") ~= nil
    or in_zone("in_mathzone")
    or in_zone("in_comment")
    or in_zone("in", verbatim_zones)
end

local function double_quote()
  local before = around_cursor()
  if keeps_straight_quote(before) then
    return '"'
  end
  local last_two = before:sub(-2)
  if last_two == "``" or last_two == "''" then
    return BACKSPACE:rep(2) .. '"'
  end
  if before == "" or before:find("[%s%(%[{`~]$") then
    return "``"
  end
  return "''"
end

local function backspace()
  local before, after = around_cursor()
  local closer = closer_for(before)
  if closer and after:sub(1, #closer) == closer then
    return BACKSPACE .. DELETE:rep(#closer)
  end
  return require("mini.pairs").bs()
end

local function enter()
  local before, after = around_cursor()
  if closer_for(before) == "\\]" and after:sub(1, 2) == "\\]" then
    return key("<CR><C-o>O")
  end
  return require("mini.pairs").cr()
end

function M.attach(buf)
  local function map(lhs, rhs)
    vim.keymap.set("i", lhs, function()
      if vim.g.minipairs_disable or vim.b.minipairs_disable then
        return key(lhs)
      end
      return rhs()
    end, { buffer = buf, expr = true, replace_keycodes = false, desc = "LaTeX pairs" })
  end

  require("mini.pairs").map_buf(buf, "i", "$", {
    action = "closeopen",
    pair = "$$",
    neigh_pattern = "[^\\].",
    register = { cr = false },
  })

  for open, close in pairs(brackets) do
    map(open, function()
      return open_bracket(open, close)
    end)
    if open ~= close then
      map(close, function()
        return close_bracket(open, close)
      end)
    end
  end

  map("$", dollar)
  map('"', double_quote)
  map("<BS>", backspace)
  map("<CR>", enter)

  vim.keymap.set("i", "`", "`", { buffer = buf, desc = "LaTeX quote" })
  vim.keymap.set("i", "'", "'", { buffer = buf, desc = "LaTeX quote" })
end

return M
