return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {
          mason = false,
          cmd = { "ocamllsp", "--fallback-read-dot-merlin" },
          root_markers = {
            function(name)
              return name:match("^[^.].*%.opam$") ~= nil
            end,
            "esy.json",
            "package.json",
            ".git",
            "dune-project",
            "dune-workspace",
            function(name)
              return name:match("%.ml$") ~= nil
            end,
          },
        },
      },
    },
  },
}
