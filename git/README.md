# Git configuration

A `.gitconfig` with sane defaults, useful aliases, and no personal
information baked in — safe to publish. Your actual identity (name, email,
optionally a signing key) lives in a **separate, untracked file** on your
machine.

## Why the split

`.gitconfig` traditionally has a `[user]` block with your real name and
email directly inside it. Publishing that file as-is means publishing your
personal contact info in a public repo forever (even if you later delete
it, it stays in git history).

The fix: keep identity out of the tracked file entirely, and have Git pull
it in from a second file that never gets committed.

```ini
[include]
    path = ~/.gitconfig.local
```

This line — already at the bottom of `.gitconfig` — tells Git to also read
`~/.gitconfig.local` and merge its settings in. Git ignores this line
silently if that file doesn't exist, so the tracked config alone is still
valid (just without a configured identity) if someone else uses it as-is.

## Files in this folder

| File | Tracked? | Purpose |
| --- | --- | --- |
| `.gitconfig` | ✅ yes | Everything generic — aliases, diff/merge behavior, colors, push/pull defaults. Safe to publish. |
| `gitconfig.local.example` | ✅ yes | Template showing what `.gitconfig.local` should contain. Documents the pattern without exposing real data. |
| `.gitconfig.local` | ❌ **no** | Your actual name/email (and signing key, if used). Machine-specific, never committed. |

## Installation

```sh
cp .gitconfig ~/.gitconfig
cp gitconfig.local.example ~/.gitconfig.local
```

Then edit `~/.gitconfig.local` and fill in your real name and email:

```ini
[user]
    name = Your Name
    email = you@example.com
```

Make sure your dotfiles repo's `.gitignore` includes:

```sh
.gitconfig.local
```

so you can never accidentally `git add` it later.

## Per-context identity (optional)

If you use different emails for different contexts — e.g. a personal
email for personal projects, a work email for anything under `~/work/` —
Git supports conditional includes instead of a single flat one:

```ini
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work.local
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal.local
```

Each path only loads when the repository you're working in lives under
the matching folder — Git checks this automatically per-repo, no manual
switching needed.

## What's in the tracked config

| Section | What it does |
| --- | --- |
| **init** | New repos default to `main` instead of `master` |
| **core** | Normalizes line endings on checkout (`autocrlf = input`), flags trailing whitespace issues |
| **push/pull** | Push only the current branch by default; auto-create matching upstream branches; merge (not rebase) on pull |
| **fetch** | Auto-prune deleted remote branches and tags; verify object integrity on fetch |
| **merge** | Three-way conflict markers with common-ancestor context (`zdiff3`) |
| **diff** | Histogram diff algorithm (often more readable than the default); highlights moved code blocks |
| **rerere** | Remembers how you resolved a conflict before, and reapplies it automatically if it recurs |
| **branch/tag sort** | Branches sorted by most-recently-committed; tags sorted by version number, not alphabetically |
| **commit** | Shows the diff inline while writing a commit message |
| **status** | Shows all untracked files (not truncated) and a submodule change summary |

### Aliases

A grab-bag of shortcuts, grouped by purpose in the file itself (status,
history, changes, cleanup, etc.) — the most worth calling out:

- `git lg` — a compact, graphed, colored one-line log across all branches
- `git gone` — deletes local branches whose remote tracking branch no
  longer exists (already merged/deleted PRs, typically)
- `git find <term>` — searches commit messages across all branches
- `git amend` — shortcut for `commit --amend`

## GPG/SSH commit signing

If you sign commits, add the relevant keys to `.gitconfig.local` (not the
tracked file) — `gitconfig.local.example` has a commented-out template for
this. Signing keys are exactly the kind of machine/person-specific data
this split is meant to keep out of the public file.
