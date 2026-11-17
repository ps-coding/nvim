local function opam_package(name)
  return name:match("^[^.].*%.opam$") ~= nil
end

local function ocaml_source(name)
  return name:match("%.ml$") ~= nil
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
      servers = {
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
