# Homebrew bundle

This directory contains the macOS command-line baseline for this dotfiles
setup. It deliberately includes only CLI tools shared by the Git, Zsh, and Vim
workflow; GUI applications and machine-specific preferences remain outside
version control.

After installing [Homebrew](https://brew.sh), install the declared packages:

```sh
brew bundle --file="./brew/Brewfile"
```

To check whether the machine matches the file without changing anything:

```sh
brew bundle check --file="./brew/Brewfile"
```

The Brewfile is macOS-only; use the native package manager on Linux or Windows.
