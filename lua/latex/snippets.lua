local M = {}

local variables = {}
for name in
  (
    "alpha beta gamma delta epsilon varepsilon zeta eta theta vartheta iota kappa lambda mu nu xi "
    .. "pi varpi rho varrho sigma varsigma tau upsilon phi varphi chi psi omega ell "
    .. "Gamma Delta Theta Lambda Xi Pi Sigma Upsilon Phi Psi Omega"
  ):gmatch("%a+")
do
  variables[name] = true
end

local function follows_plain_command(line, subscript)
  local slashes, command = line:match("(\\+)(%a+)" .. subscript .. "$")
  return slashes ~= nil and #slashes % 2 == 1 and not variables[command]
end

local function longer_subscript(is_math)
  local luasnip = require("luasnip")
  return luasnip.snippet({
    trig = "(%a)_{(%d+)}(%d)",
    name = "auto subscript continued",
    trigEngine = "pattern",
    wordTrig = false,
    condition = function(line)
      return not follows_plain_command(line, "_{%d+}%d") and is_math()
    end,
  }, {
    luasnip.function_node(function(_, snippet)
      return ("%s_{%s%s}"):format(unpack(snippet.captures))
    end),
    luasnip.insert_node(0),
  })
end

function M.setup(opts)
  local ok, subscripts = pcall(require, "luasnip-latex-snippets.math_wrA")
  if ok then
    local retrieve = subscripts.retrieve
    subscripts.retrieve = function(is_math)
      local snippets = retrieve(function(line)
        return not follows_plain_command(line, "%d") and is_math()
      end)
      snippets[#snippets + 1] = longer_subscript(is_math)
      return snippets
    end
  end
  require("luasnip-latex-snippets").setup(opts)
  if not pcall(vim.api.nvim_exec_autocmds, "FileType", { group = "luasnip-latex-snippets", pattern = "tex" }) then
    vim.api.nvim_exec_autocmds("FileType", { pattern = "tex" })
  end
end

function M.load_on_insert(buf)
  vim.api.nvim_create_autocmd("InsertEnter", {
    buffer = buf,
    once = true,
    callback = function()
      require("lazy").load({ plugins = { "luasnip-latex-snippets.nvim" } })
    end,
  })
end

return M
