# Prasham's Neovim Configuration

Built on [LazyVim](https://github.com/LazyVim/LazyVim). Everything here adds to or overrides its defaults; anything not mentioned is stock.

## Layout

| Path | Purpose |
| --- | --- |
| `lua/config/lazy.lua` | lazy.nvim bootstrap |
| `lua/config/options.lua` | Editor options |
| `lua/plugins/colorscheme.lua` | Transparent tokyonight, tuned to the terminal backdrop |
| `lua/plugins/completion.lua` | Completion keys, which suggestions get highlighted, menu and documentation windows |
| `lua/plugins/dashboard.lua` | Start screen |
| `lua/plugins/git.lua` | Octo keys |
| `lua/plugins/latex.lua` | vimtex, texlab completion fixes, math snippets |
| `lua/plugins/lean.lua` | Hands LazyVim's Lean settings to lean.nvim |
| `lua/plugins/lsp.lua` | Diagnostics, code lenses, and per-server fixes (OCaml, Kotlin, Angular, Ruby, ESLint) |
| `lua/plugins/org.lua` | Org mode, loaded on demand |
| `lua/plugins/pdf.lua` | PDF reader |
| `lua/plugins/ui.lua` | Statusline and popup borders |
| `lua/latex/pairs.lua` | LaTeX delimiter and quote typing |
| `lua/latex/completion.lua` | LaTeX completion rules |
| `lua/latex/snippets.lua` | Subscript rules layered on the snippet pack |
| `after/ftplugin/` | Per-filetype setup (`tex`, `tsv`) |

Plugin files only declare specs. The `lua/latex/` modules hold the logic and load on demand, so none of it runs at startup.

## Completion

A highlighted row is the one Enter takes. What gets highlighted depends on the file:

| File type | Highlighted | Enter | Tab |
| --- | --- | --- | --- |
| Code | Top suggestion, unless accepting it would change nothing | Accepts a highlighted row, otherwise a line break | Next snippet field, otherwise accepts the top suggestion |
| Writing (LaTeX, Markdown, text, commit messages, org, ...) | Top suggestion only if it comes from the language server and would change the text | Accepts a highlighted row, otherwise a line break | Accepts a highlighted row, otherwise next snippet field, otherwise accepts the top suggestion |
| Tab-separated (`tsv`) | As for code | As for code | Always a tab character |

With no menu open, Tab indents. The lists of writing and tab-separated file types are at the top of `lua/plugins/completion.lua`.

"Would change nothing" means the word is already typed in full and the suggestion adds no call brackets, import or snippet, so Enter after `else`, `return` or a finished name starts a new line.

Snippets are not offered straight after `.`, `:` or `->`, where only members make sense.

In LaTeX, snippets are offered for bare words (`frac`, `table`, `fig`) and texlab answers after a backslash or inside a command's braces.

## LaTeX typing

- **Delimiters** close automatically when the opening bracket is typed: `\(`, `\[`, `\{`, and `(`, `[`, `\{`, `|`, `\|` after `\left`, `\bigl`, `\Bigl`, `\biggl`, `\Biggl`, `\big`, `\Big`, `\bigg` or `\Bigg`. Typing the closing bracket steps over the whole closer, and typing the closer by hand replaces it. Backspace between an empty pair removes both.
- **Named delimiters** such as `\langle` are closed by vimtex: type `]]` in insert mode.
- **Quotes:** `"` becomes ` `` ` when opening and `''` when closing. Press `"` twice for a straight quote. It stays straight in math, comments, verbatim, listings, `\texttt` and after a backslash.
- **Dollar signs** pair, and a second `$` inside an empty pair opens a display block.
- **Subscripts:** a digit after a variable becomes a subscript (`x1`, `x12`, `\alpha1`), but not after other commands (`\frac12`, `\sqrt2`).
- `<leader>up` toggles all of the pairing.

## Maintenance

- **Backdrop colour.** `backdrop` in `lua/plugins/colorscheme.lua` is the colour the terminal shows behind text, sampled from a screenshot. Re-sample it if the wallpaper or terminal opacity changes.
- **Internals this config relies on.** Each is guarded so that an upstream rename brings back the original behaviour and raises no error:
  - blink.cmp's `sources.lsp.cache` module, cleared so texlab is asked again on every keystroke (`lua/latex/completion.lua`).
  - luasnip-latex-snippets' `math_wrA` module and `luasnip-latex-snippets` autocmd group (`lua/latex/snippets.lua`).
  - snacks.image's `placement.new`, namespace and `SnacksImageLoading` highlight, used to remove the leftover loading label on PDF pages (`lua/plugins/pdf.lua`).
  - tokyonight's `util.bg`, set so blended colours use the real backdrop (`lua/plugins/colorscheme.lua`).
- **Upstream workarounds.** Each can be deleted once the project named fixes it:
  - lean.nvim reads `vim.g.lean_config` and no longer has `setup()`, which LazyVim's Lean extra still calls (`lua/plugins/lean.lua`).
  - nvim-lspconfig works out the Kotlin server's cache folder once, from whichever file is open first, and sends an empty list when there is none; the server then refuses to start. It is now set per project (`kotlin_storage`).
  - nvim-lspconfig starts the Angular server for every TypeScript and HTML file. It is limited to Angular and Nx workspaces (`angularls`).
  - LazyVim's ESLint formatter runs prettier instead of ESLint whenever prettier handles the file type, so ESLint fixes were never applied on save (`register_eslint_fixes`).
  - LazyVim runs the Ruby language server and a separate RuboCop server together, which doubles every offence when the bundle includes RuboCop. The separate server now steps aside in that case (`standalone_rubocop_root`).
