# Git Configuration

This directory contains Git configuration that will be symlinked to `~/.config/git/` following the XDG Base Directory specification.

## XDG Base Directory Standard

This configuration uses the XDG Base Directory standard location for Git config files. Git supports reading configuration from `~/.config/git/config` as an alternative to the traditional `~/.gitconfig` location.

### Why XDG?

The XDG Base Directory specification helps organize configuration files in a consistent way:
- Keeps `$HOME` cleaner by consolidating configs in `~/.config/`
- Follows modern Linux/Unix conventions
- Consistent with other tools in this dotconfig repository (nvim, fish, wezterm, etc.)

## Configuration Precedence

Git reads configuration in this order (later sources override earlier ones):

1. **System**: `/etc/gitconfig` - System-wide configuration
2. **Global XDG**: `~/.config/git/config` - User-level configuration (XDG location) ← **This file**
3. **Global Legacy**: `~/.gitconfig` - User-level configuration (traditional location)
4. **Local**: `.git/config` - Repository-specific configuration

### Important Notes

- If you have settings in both `~/.config/git/config` and `~/.gitconfig`, the settings in `~/.gitconfig` will take precedence
- You can verify which config file Git is reading by running:
  ```bash
  git config --list --show-origin
  ```
- Repository-level settings (`.git/config`) always override global settings

## Current Configuration

### `init.defaultBranch = main`

Sets the default branch name to `main` when creating new repositories with `git init`. This replaces the historical default of `master` with the more modern convention.

## Managing Your Git Configuration

### Using This Config

When you run the justfile sync command, this directory will be symlinked to `~/.config/git/`. Any changes you make here will be reflected in your Git configuration.

### Migrating from ~/.gitconfig

If you have existing settings in `~/.gitconfig`:

1. **Option 1 - Keep both**: Leave your `~/.gitconfig` as-is. Settings there will override these settings due to Git's precedence order.

2. **Option 2 - Consolidate**: Move your settings from `~/.gitconfig` into this `config` file if you want everything in one XDG-compliant location. Remember to remove or rename your old `~/.gitconfig`.

3. **Option 3 - Hybrid**: Keep personal settings (name, email, signing keys) in `~/.gitconfig` and use this file for general preferences and tool defaults.

### Testing

After setting up, verify Git is reading your config:

```bash
# See all config sources
git config --list --show-origin

# Check a specific setting
git config --show-origin init.defaultBranch

# Test creating a new repo
mkdir test-repo && cd test-repo
git init
git branch --show-current  # Should show "main"
```

## Adding More Settings

Feel free to extend this configuration with additional Git settings. Common additions might include:

```ini
[core]
    editor = nvim
    autocrlf = input

[pull]
    rebase = false

[push]
    default = simple

[alias]
    st = status
    co = checkout
    br = branch
```

Just remember that any personal information (name, email, GPG keys) might be better kept in your local `~/.gitconfig` if you're sharing or backing up this dotconfig repository.
