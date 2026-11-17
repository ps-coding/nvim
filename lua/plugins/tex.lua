local function is_tex(ctx)
  return vim.bo[ctx.bufnr].filetype == "tex"
end

local function in_command(ctx)
  local before = ctx.line:sub(1, ctx.bounds.start_col - 1)
  local argument = before:match("{([^{}]*)$")
  return before:sub(-1) == "\\" or (argument ~= nil and not argument:gsub(",%s*", ","):find("%s"))
end

return {
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = {
          function()
            return LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" })()
          end,
          function(cmp)
            if vim.bo.filetype == "tex" and cmp.is_menu_visible() then
              return cmp.select_and_accept()
            end
          end,
          "fallback",
        },
      },
      completion = {
        accept = { auto_brackets = { blocked_filetypes = { "tex" } } },
        list = {
          selection = {
            preselect = function(ctx)
              return not is_tex(ctx) or in_command(ctx)
            end,
          },
        },
      },
      sources = {
        providers = {
          snippets = {
            should_show_items = function(ctx)
              return not (is_tex(ctx) and in_command(ctx))
            end,
          },
          lsp = {
            override = {
              get_completions = function(self, ctx, callback)
                local tex = is_tex(ctx)
                if tex then
                  local ok, cache = pcall(require, "blink.cmp.sources.lsp.cache")
                  if ok then
                    cache.entries = {}
                  end
                end
                return self:get_completions(ctx, function(response)
                  if tex and response then
                    response.is_incomplete_forward = true
                    response.is_incomplete_backward = true
                  end
                  callback(response)
                end)
              end,
            },
          },
        },
      },
    },
  },
}
