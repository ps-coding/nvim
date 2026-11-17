local function opam_package(name)
  return name:match("^[^.].*%.opam$") ~= nil
end

local function ocaml_source(name)
  return name:match("%.ml$") ~= nil
end

local function read(path)
  local file = io.open(path)
  if not file then
    return nil
  end
  local text = file:read("*a")
  file:close()
  return text
end

local function ruby_lsp_runs_rubocop(root)
  local lock = root and read(vim.fs.joinpath(root, "Gemfile.lock"))
  if not lock then
    return false
  end
  local direct = lock:match("\nDEPENDENCIES\n(.-)\n\n") or lock:match("\nDEPENDENCIES\n(.*)") or ""
  if ("\n" .. direct):find("\n  rubocop") then
    return true
  end
  return lock:find("\n    rubocop %(") ~= nil and vim.uv.fs_stat(vim.fs.joinpath(root, ".rubocop.yml")) ~= nil
end

local function standalone_rubocop_root(buf, on_dir)
  local root = vim.fs.root(buf, { "Gemfile", ".git" })
  if not ruby_lsp_runs_rubocop(root) then
    on_dir(root)
  end
end

local function kotlin_storage(params, config)
  local options = vim.empty_dict()
  options.storagePath = config.root_dir
  params.initializationOptions = options
end

local function fix_with_eslint(buf)
  require("conform").format({ bufnr = buf, name = "eslint", formatters = {}, lsp_format = "fallback" })
end

local function register_eslint_fixes()
  if vim.g.lazyvim_eslint_auto_format == false then
    return
  end
  LazyVim.format.register(LazyVim.lsp.formatter({
    name = "eslint: lsp",
    primary = false,
    priority = 200,
    filter = "eslint",
    format = fix_with_eslint,
  }))
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { current_line = false },
        virtual_lines = { current_line = true },
      },
      codelens = { enabled = true },
      setup = { eslint = register_eslint_fixes },
      servers = {
        angularls = { workspace_required = true },
        kotlin_language_server = { before_init = kotlin_storage },
        rubocop = { root_dir = standalone_rubocop_root },
        ocamllsp = {
          mason = false,
          cmd = { "ocamllsp", "--fallback-read-dot-merlin" },
          root_markers = {
            opam_package,
            "esy.json",
            "package.json",
            ".git",
            "dune-project",
            "dune-workspace",
            ocaml_source,
          },
        },
      },
    },
  },
}
