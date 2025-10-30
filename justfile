# Configuration directory (defaults to $HOME/.config)
config_dir := env_var_or_default('CONFIG_DIR', env_var('HOME') + '/.config')

# Get the absolute path to this repository
repo_dir := justfile_directory()

# Default recipe - link all configurations
default: link

# List available tool configurations
list:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Available tool configurations:"
    for dir in "{{repo_dir}}"/*; do
        if [ -d "$dir" ] && [ "$(basename "$dir")" != ".git" ] && [ "$(basename "$dir")" != ".github" ]; then
            tool=$(basename "$dir")
            echo "  - $tool"
        fi
    done

# Link tool configurations to config directory
link TOOL="":
    #!/usr/bin/env bash
    set -euo pipefail

    link_tool() {
        local tool=$1
        local source="{{repo_dir}}/$tool"
        local target="{{config_dir}}/$tool"

        # Skip if source doesn't exist or isn't a directory
        if [ ! -d "$source" ]; then
            return
        fi

        # Check if target already exists
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ -L "$target" ]; then
                current_link=$(readlink "$target")
                if [ "$current_link" = "$source" ]; then
                    echo "✓ $tool (already linked)"
                    return
                else
                    echo "⚠ $tool (linked to different location: $current_link)"
                    read -p "  Replace? (y/N) " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        return
                    fi
                    rm "$target"
                fi
            else
                echo "⚠ $tool (existing file/directory at $target)"
                read -p "  Backup and replace? (y/N) " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    return
                fi
                mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
            fi
        fi

        # Create parent directory if it doesn't exist
        mkdir -p "{{config_dir}}"

        # Create symlink
        ln -s "$source" "$target"
        echo "✓ $tool (linked)"
    }

    if [ -n "{{TOOL}}" ]; then
        # Link specific tool
        link_tool "{{TOOL}}"
    else
        # Link all tools
        for dir in "{{repo_dir}}"/*; do
            if [ -d "$dir" ] && [ "$(basename "$dir")" != ".git" ] && [ "$(basename "$dir")" != ".github" ]; then
                tool=$(basename "$dir")
                link_tool "$tool"
            fi
        done
    fi

# Unlink tool configurations from config directory
unlink TOOL="":
    #!/usr/bin/env bash
    set -euo pipefail

    unlink_tool() {
        local tool=$1
        local target="{{config_dir}}/$tool"
        local source="{{repo_dir}}/$tool"

        # Check if target exists and is a symlink
        if [ -L "$target" ]; then
            current_link=$(readlink "$target")
            if [ "$current_link" = "$source" ]; then
                rm "$target"
                echo "✓ $tool (unlinked)"
            else
                echo "⚠ $tool (linked to different location, skipping)"
            fi
        elif [ -e "$target" ]; then
            echo "⚠ $tool (not a symlink, skipping)"
        else
            echo "- $tool (not linked)"
        fi
    }

    if [ -n "{{TOOL}}" ]; then
        # Unlink specific tool
        unlink_tool "{{TOOL}}"
    else
        # Unlink all tools
        for dir in "{{repo_dir}}"/*; do
            if [ -d "$dir" ] && [ "$(basename "$dir")" != ".git" ] && [ "$(basename "$dir")" != ".github" ]; then
                tool=$(basename "$dir")
                unlink_tool "$tool"
            fi
        done
    fi

# Show status of tool configurations
status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Configuration status:"
    echo "  Repo: {{repo_dir}}"
    echo "  Target: {{config_dir}}"
    echo ""
    for dir in "{{repo_dir}}"/*; do
        if [ -d "$dir" ] && [ "$(basename "$dir")" != ".git" ] && [ "$(basename "$dir")" != ".github" ]; then
            tool=$(basename "$dir")
            target="{{config_dir}}/$tool"
            source="{{repo_dir}}/$tool"

            if [ -L "$target" ]; then
                current_link=$(readlink "$target")
                if [ "$current_link" = "$source" ]; then
                    echo "  ✓ $tool → linked"
                else
                    echo "  ⚠ $tool → linked elsewhere ($current_link)"
                fi
            elif [ -e "$target" ]; then
                echo "  ✗ $tool → exists but not linked"
            else
                echo "  - $tool → not linked"
            fi
        fi
    done

# Show help
help:
    @echo "Config Management Tool"
    @echo ""
    @echo "Usage:"
    @echo "  just              Link all tool configurations"
    @echo "  just link [TOOL]  Link specific tool or all tools"
    @echo "  just unlink [TOOL] Unlink specific tool or all tools"
    @echo "  just status       Show link status"
    @echo "  just list         List available tools"
    @echo "  just help         Show this help message"
    @echo ""
    @echo "Environment Variables:"
    @echo "  CONFIG_DIR        Target directory (default: \$HOME/.config)"
