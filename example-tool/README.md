# Example Tool Configuration

This is an example directory showing how to structure tool configurations.

## Structure

Each tool should have its own directory in the repository root:
```
.config/
├── example-tool/     # This directory
│   ├── config.conf   # Tool configuration files
│   └── README.md     # Optional documentation
├── another-tool/     # Another tool's config
│   └── settings.json
└── justfile          # Command runner
```

## How It Works

When you run `just link`, this entire directory gets symlinked to `$HOME/.config/example-tool/`, making all configuration files available to the tool.

## Adding Your Own Tools

1. Create a directory with your tool's name (e.g., `nvim`, `fish`, `wezterm`)
2. Add the tool's configuration files inside
3. Run `just link` to symlink it to your config directory
4. Optionally add a README to document tool-specific setup

You can delete this example-tool directory once you understand the structure.
