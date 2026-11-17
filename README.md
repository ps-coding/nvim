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
| `lua/plugins/lsp.lua` | Diagnostics, code lenses, OCaml project roots |
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
| Code | Top suggestion, always | Accepts it | Next snippet field, otherwise accepts the top suggestion |
| Writing (LaTeX, Markdown, text, commit messages, org, ...) | Top suggestion only if it comes from the language server and would change the text | Accepts a highlighted row, otherwise a line break | Accepts a highlighted row, otherwise next snippet field, otherwise accepts the top suggestion |
| Tab-separated (`tsv`) | As for code | Accepts it | Always a tab character |

With no menu open, Tab indents. The lists of writing and tab-separated file types are at the top of `lua/plugins/completion.lua`.

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
