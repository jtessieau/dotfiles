# Dotfiles

My personal collection of configuration files, shell setup, Git configuration, editor settings, and reusable development templates.

The goal of this repository is to make my development environment **portable, reproducible, and easy to rebuild** on a new machine.

## Contents

```text
.
├── zsh/          # Zsh configuration
├── brew/         # Homebrew configuration / package lists
├── git/          # Git configuration
├── vim/          # Vim configuration
├── vscode/       # VS Code templates and settings
├── prettier/     # Prettier configuration/templates
└── README.md
```

> The structure may evolve as more configuration is added.

## Philosophy

This repository is not intended to contain every possible configuration file from my machines.

Instead, it contains the configuration that is:

- **Useful** across multiple machines
- **Worth keeping** under version control
- **Easy to reproduce**
- **Safe to share**

Machine-specific configuration, secrets, credentials, API keys, and other sensitive information should **never** be committed to this repository.

## Usage

Clone the repository:

```bash
git clone <repository-url>
cd dotfiles
```

Individual configurations can then be copied or linked into the appropriate location.

For example:

```bash
ln -s "$PWD/zsh/.zshrc" "$HOME/.zshrc"
```

The exact installation process may evolve as the repository grows.

## Configuration

### Zsh

Contains my Zsh configuration, including shell aliases, functions, environment configuration, and prompt setup.

### Homebrew

Contains information required to reproduce my Homebrew environment, such as installed packages and applications.

### Git

Contains my Git configuration, aliases, and other Git-related settings.

Personal credentials and authentication details are intentionally kept outside the repository.

### Vim

Contains my Vim configuration and editor customisation.

### VS Code

Contains reusable VS Code configuration/templates.

These are intended to provide a consistent development environment without necessarily forcing the same configuration onto every project.

### Prettier

Contains reusable Prettier configuration/templates for projects that use Prettier.

## Templates

Some files in this repository are intended to be **copied into projects** rather than installed globally.

For example:

```text
vscode/
└── ...
    
prettier/
└── ...
```

This allows project-specific configuration to remain in the project while keeping the source template maintained in one place.

## Secrets

This repository is intended to be safe to keep on a public or shared Git remote.

Never commit:

- Passwords
- API keys
- SSH private keys
- Access tokens
- Personal credentials
- Machine-specific secrets
- `.env` files containing secrets

When configuration requires sensitive values, use environment variables or a separate local configuration file.

## Adding a New Configuration

When adding something new, the preferred approach is:

1. Create a dedicated directory if appropriate.
2. Keep the configuration as portable as possible.
3. Separate machine-specific settings from reusable settings.
4. Remove secrets and personal credentials.
5. Add installation instructions if the configuration is not self-explanatory.
6. Update this README when the repository structure changes.

## Future

Possible additions include:

- Terminal / shell tools
- Starship
- SSH configuration
- tmux
- Neovim
- Development tool configuration
- Additional project templates
- Installation/bootstrap scripts

The repository should remain useful even when starting from a completely fresh machine
