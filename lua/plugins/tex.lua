local function is_tex(ctx)
  return vim.bo[ctx.bufnr].filetype == "tex"
end

local function in_command(ctx)
  local before = ctx.line:sub(1, ctx.bounds.start_col - 1)
  return before:sub(-1) == "\\" or before:match("{[^{}]*$") ~= nil
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
