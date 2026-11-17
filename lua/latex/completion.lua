local M = {}

function M.in_command(ctx)
  local before = ctx.line:sub(1, ctx.bounds.start_col - 1)
  if before:sub(-1) == "\\" then
    return true
  end
  local argument = before:match("{([^{}]*)$")
  return argument ~= nil and not argument:gsub(",%s*", ","):find("%s")
end

function M.request_fresh(source, ctx, callback)
  local ok, cache = pcall(require, "blink.cmp.sources.lsp.cache")
  if ok then
    cache.entries = {}
  end
  return source:get_completions(ctx, function(response)
    if response then
      response.is_incomplete_forward = true
      response.is_incomplete_backward = true
    end
    callback(response)
  end)
end

return M
