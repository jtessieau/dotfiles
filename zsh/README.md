# Standalone Zsh config with a powerline-style prompt

A single `.zshrc` that reproduces an [oh-my-posh](https://ohmyposh.dev/)-style
powerline prompt — diamond segment caps, a git status block, root/SSH
awareness — **without installing oh-my-zsh, oh-my-posh, or any prompt
framework**. Everything lives in one file and only depends on Zsh itself,
plus the `git` CLI when you're inside a repository.

## Requirements

### 1. A Nerd Font (required)

The prompt uses [Powerline](https://github.com/powerline/fonts) and
[Nerd Font](https://www.nerdfonts.com/) glyphs for the arrows, diamond caps,
folder/branch/status icons, and the SSH indicator. These are private-use
Unicode codepoints (e.g. `U+E0B0`) that **only exist in patched fonts** —
without one, the prompt will show boxes, question marks, or blank squares
instead of arrows and icons.

Install any Nerd Font and set it as your terminal's font. Popular picks:

- [MesloLGS NF](https://github.com/ryanoasis/nerd-fonts/releases) — the most
  common choice for powerline-style prompts
- [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)

After installing, point your terminal emulator's font setting at the Nerd
Font variant (e.g. `MesloLGS NF`, not plain `Meslo`). This is a terminal
setting, not something `.zshrc` can configure — check your terminal's
preferences/profile settings.

### 2. A true-color (24-bit) terminal

Segment colors are specified as 24-bit hex (`#F07623`, etc.), which Zsh
renders natively via `%F{#rrggbb}` / `%K{#rrggbb}` (supported since Zsh
5.8). Nearly all modern terminals support true color out of the box —
iTerm2, Windows Terminal, GNOME Terminal, Alacritty, Kitty, Konsole, and
recent versions of Terminal.app all work. If colors look flattened or
wrong, your terminal may be falling back to a reduced 256-color palette.

### 3. (Optional) `zsh-syntax-highlighting` and `zsh-autosuggestions`

The end of `.zshrc` sources these two plugins if they're installed via your
package manager, e.g. on Debian/Ubuntu:

```sh
sudo apt install zsh-syntax-highlighting zsh-autosuggestions
```

They're optional — the prompt itself works without them. If they aren't
installed, those two `source` lines silently no-op (guarded by `[[ -r ... ]]`
checks) rather than erroring.

## Installation

```sh
cp .zshrc ~/.zshrc
exec zsh          # reload without closing your terminal
```

## What's in the prompt

Left to right, the prompt is built from five segments, each only shown when
relevant:

| Segment | Shown | Color | Content |
| --- | --- | --- | --- |
| **Session** | always | yellow | your username; prefixed with an SSH icon when connected over SSH |
| **Path** | always | orange | the current directory's last path component (not the full path) |
| **Git** | inside a git repo | green (reacts to state — see below) | branch name, ahead/behind counts, dirty indicators |
| **Root** | only as root (`UID == 0`) | yellow | a bolt icon |
| **Status** | always | blue / red | checkmark on success, cross if the last command failed |

### Git segment color logic

The background (and text color) shifts based on repository state, evaluated
in this order — **later conditions override earlier ones** if more than one
is true at once:

1. Clean, tracked branch → green
2. Uncommitted changes (staged or unstaged) → yellow
3. Ahead *and* behind the remote (diverged) → red
4. Ahead of the remote only → dark purple
5. Behind the remote only → magenta

The branch text itself shows:

- An upstream icon ( GitHub /  GitLab /  Bitbucket / generic) — only
  if the branch tracks a remote
- `↑N` / `↓N` — commits ahead/behind the remote
- `≡` — fully in sync with a tracked remote (no ahead, no behind)
- A pencil icon — unstaged (working tree) changes present
- A filled-box icon — staged (index) changes present

### The black diamond gap

Between every pair of segments you'll see a solid black wedge rather than a
single blended arrow. This is two triangles drawn back-to-back: one
pointing right in the *previous* segment's color (on a black background),
immediately followed by one pointing left in black (on the *next* segment's
background) — together they form the diamond gap.

## Customizing

All colors live in one block near the top of the prompt section as
`P_BLACK`, `P_BLUE`, `P_GREEN`, `P_ORANGE`, `P_RED`, `P_WHITE`, `P_YELLOW` —
change a value there to re-theme every segment that uses it. Icons are
similarly pulled out into named variables (`FOLDER_ICON`, `BRANCH_ICON`,
etc.) if you want to swap glyphs; browse available codepoints at
[nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet).

To show more of the current path instead of just the folder name, change
`%1~` to `%2~` (last two components) or `%~` (full path) in `prompt_path`.

## Private / per-machine settings

`.zshrc` sources `~/.zshrc.local` if it exists (see the line near the top).
Use that file for anything machine-specific or private — extra `PATH`
entries, work aliases, API keys — and add it to your global gitignore so it
never ends up in version control alongside this file.
