local writing = {
  asciidoc = true,
  gitcommit = true,
  mail = true,
  markdown = true,
  norg = true,
  octo = true,
  org = true,
  plaintex = true,
  quarto = true,
  rmd = true,
  rst = true,
  tex = true,
  text = true,
  typst = true,
}

local tab_separated = { tsv = true }

local function changes_text(item, ctx)
  if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
    return true
  end
  local text = item.textEdit and item.textEdit.newText or item.insertText or item.label
  return text ~= ctx.line:sub(ctx.bounds.start_col, ctx.cursor[2])
end

local function preselect(ctx)
  if not writing[vim.bo[ctx.bufnr].filetype] then
    return true
  end
  local top = require("blink.cmp").get_items()[1]
  return top ~= nil and top.source_id == "lsp" and changes_text(top, ctx)
end

local function jump_to_next_snippet_field()
  local ok, luasnip = pcall(require, "luasnip")
  if ok and luasnip.locally_jumpable(1) then
    vim.schedule(function()
      luasnip.jump(1)
    end)
    return true
  end
end

local function tab(cmp)
  local filetype = vim.bo.filetype
  if tab_separated[filetype] then
    return
  end
  if writing[filetype] and cmp.is_menu_visible() and cmp.get_selected_item() then
    return cmp.accept()
  end
  if jump_to_next_snippet_field() or LazyVim.cmp.map({ "ai_nes", "ai_accept" })() then
    return true
  end
  if cmp.is_menu_visible() then
    return cmp.select_and_accept()
  end
end

local function menu_columns(ctx)
  local columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } }
  if ctx.mode ~= "cmdline" then
    columns[#columns + 1] = { "kind" }
  end
  return columns
end

local function draw_documentation(opts)
  opts.default_implementation()
  local text = table.concat(vim.api.nvim_buf_get_lines(opts.window:get_buf(), 0, -1, false), "\n")
  text = text:gsub("</?text>", ""):gsub("```%w*", "")
  if not text:find("%S") then
    vim.schedule(function()
      require("blink.cmp").hide_documentation()
    end)
  end
end

return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = { tab, "fallback" },
      },
      completion = {
        list = { selection = { preselect = preselect } },
        menu = {
          scrollbar = false,
          draw = { columns = menu_columns },
        },
        documentation = {
          window = { scrollbar = false },
          draw = draw_documentation,
        },
      },
    },
  },
}
