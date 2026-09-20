# Vim configuration

A single `.vimrc` — no plugin manager, no external plugins. Everything here
is built into Vim itself, so it works the moment you copy the file in.

## Requirements

### Vim version

Uses only built-in features:

- `habamax` colorscheme — bundled with Vim 8.2+ and all Neovim versions.
  If your Vim is older and doesn't have it, either upgrade or swap the
  `colorscheme habamax` line for another built-in scheme (`:colorscheme` + `<Tab>` in Vim lists what's available on your system).
- `termguicolors` — needs a terminal that supports 24-bit color (most
  modern terminals do). If colors look wrong, your terminal may not
  support this and Vim will fall back to its 256-color approximation.

### System clipboard (optional)

`set clipboard=unnamedplus` only works if Vim was compiled with clipboard
support. Check with:

```sh
vim --version | grep clipboard
```

`+clipboard` or `+xterm_clipboard` means it'll work. `-clipboard` means
your Vim build doesn't support it — on Debian/Ubuntu, installing the
`vim-gtk3` package (instead of plain `vim`) usually adds it.

## Installation

```sh
cp .vimrc ~/.vimrc
```

That's it — no plugin install step, no `:PlugInstall` equivalent, since
nothing here depends on an external plugin manager.

## What's in it

| Section | What it does |
| --- | --- |
| **General** | UTF-8 encoding, syntax highlighting, dark background |
| **Appearance** | Line numbers, current-line highlight, status line, mouse support, no line wrapping |
| **Colors** | `habamax` theme, with a few `highlight` tweaks for contrast |
| **Indentation** | 4-space tabs (spaces, not real tabs), smart auto-indent |
| **Searching** | Case-insensitive unless you type a capital, live search-as-you-type, `<Esc>` clears highlighted matches |
| **Editing** | Better backspace behavior, persistent undo history, no backup/swap file clutter |
| **Clipboard** | Uses the system clipboard for yank/paste when available |

### Persistent undo

```vim
set undodir=~/.vim/undo
set undofile
```

Vim remembers your undo history even after closing and reopening a file.
History is stored in `~/.vim/undo` (created automatically on first run if
it doesn't exist) rather than scattered next to the files you edit.

### No backup/swap files

```vim
set nobackup
set nowritebackup
set noswapfile
```

Vim normally creates `filename~` backups and `.filename.swp` swap files
next to whatever you're editing. This config disables both — the tradeoff
is that a crash mid-edit won't leave a recovery `.swp` file behind, but in
exchange your working directories stay free of clutter. Persistent undo
(above) covers most of what you'd otherwise use swap-file recovery for.

## Customizing

- **Relative line numbers**: uncomment `set relativenumber` if you prefer
  counting lines relative to the cursor (useful for `5dd`-style commands).
- **Cursor column guide**: uncomment `set cursorcolumn` to also highlight
  the current column, not just the current line.
- **Tab width**: change `tabstop` / `shiftwidth` / `softtabstop` (all three
  are kept in sync at 4 here; change together to avoid inconsistent
  indentation behavior).
- **Colorscheme**: swap `habamax` for any other built-in scheme, or drop in
  a plugin manager later if you want third-party themes — this file makes
  no assumptions about one being present.
