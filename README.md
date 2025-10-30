# .config

A simple, maintainable, and extensible dotfiles management system that syncs tool configurations to `$HOME/.config/` using symbolic links.

## Overview

This repository manages configuration files for various development tools. Each directory in the repository represents a tool's configuration, and running the sync command creates symbolic links from `$HOME/.config/` to this repository.

## Prerequisites

- [just](https://just.systems/) - A command runner (similar to make)
- (that's it!)

## Quick Start

1. Clone this repository:

2. Link all configurations:

   ```sh
   just
   ```

3. Check the status:

   ```sh
   just status
   ```

## Usage

### Link all configurations

```bash
just
# or
just link
```

This creates symbolic links for all tool directories to `$HOME/.config/`.

### Link a specific tool

```bash
just link nvim
```

### Unlink all configurations

```bash
just unlink
```

### Unlink a specific tool

```bash
just unlink fish
```

### Check link status

```bash
just status
```

Shows which configurations are linked, unlinked, or have conflicts.

### List available tools

```bash
just list
```

### Show help

```bash
just help
```

## Structure

This project's structure should follow the form:

```
.config/
├── README.md         # This file
├── justfile          # Command runner with sync logic
├── nvim/             # Neovim configuration
├── wezterm/          # WezTerm terminal configuration
└── ...               # Other tool configurations
```

## Adding a New Tool Configuration

1. Create a directory with the tool's name:

   ```bash
   mkdir newtool
   ```

2. Add your configuration files.
3. Link it:

   ```bash
   just link newtool
   ```

4. Commit to the repository:

   ```bash
   git add newtool
   git commit -m "Add newtool configuration"
   ```

## How It Works

- **Symbolic Links**: Instead of copying files, this system creates symlinks from `$HOME/.config/<tool>` to this repository's directories
- **Version Control**: All configurations are tracked in git
- **Safety**: The link command checks for existing files and prompts before overwriting
- **Backups**: If you choose to replace an existing configuration, it's backed up with a timestamp

## Environment Variables

### CONFIG_DIR

Override the target directory (default: `$HOME/.config`):

```bash
CONFIG_DIR=/custom/path just link
```

## Testing

This repository includes an automated test bench that verifies all functionality works correctly.

### Running Tests

```bash
./test.sh
```

The test bench will:
- Create a temporary test environment (using `CONFIG_DIR`)
- Test all recipes: `help`, `list`, `link`, `unlink`, `status`, and default
- Test linking/unlinking individual tools and all tools
- Verify the `CONFIG_DIR` environment variable works correctly
- Clean up after itself

### Test Coverage

The test bench automatically discovers all tools in the repository and tests:
- Default recipe (links all tools)
- Help message correctness
- Listing available tools
- Linking all tools
- Linking specific tools
- Linking some but not all tools
- Status reporting for linked and unlinked tools
- Unlinking all tools
- Unlinking specific tools
- Unlinking some but not all tools
- CONFIG_DIR environment variable functionality

### Extensibility

The test bench is designed to be extensible. When you add a new tool configuration directory, the test bench will automatically include it in tests without requiring any code changes.

## Tips

- **Before linking**: Check what will be linked with `just list`
- **After linking**: Verify with `just status`
- **Conflicts**: If a tool configuration already exists, you'll be prompted to backup or skip
- **Testing**: Use `CONFIG_DIR` to test linking in a different directory first

## Troubleshooting

### Permission denied

Ensure you have write permissions to `$HOME/.config/`:

```bash
ls -la ~/.config/
```

### Symlink already exists

Use `just status` to see what's linked. Unlink first if needed:

```bash
just unlink <tool>
just link <tool>
```

### Tool not found

Make sure the tool directory exists:

```bash
just list
```

## Maintenance

### Update configurations

Since files are symlinked, any changes made to configs (either in this repo or through the tool itself) are automatically reflected in both locations.

### Sync to a new machine

1. Clone this repository
2. Install just
3. Run `just link`

### Remove this system

```bash
just unlink
```

This removes all symlinks but keeps your original files.
