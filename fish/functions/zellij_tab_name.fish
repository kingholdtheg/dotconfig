# Auto-rename zellij tabs based on running command
# Renames tab to command while running, resets to directory name when done

function zellij_tab_name_update_preexec --on-event fish_preexec
    if set -q ZELLIJ
        # Get just the command name (first word)
        set -l cmd (string split ' ' -- $argv[1])[1]
        zellij action rename-tab $cmd
    end
end

function zellij_tab_name_update_postexec --on-event fish_postexec
    if set -q ZELLIJ
        zellij action rename-tab (basename $PWD)
    end
end

function zellij_tab_name_update_pwd --on-variable PWD
    if set -q ZELLIJ
        # Only update if no command is actively running
        zellij action rename-tab (basename $PWD)
    end
end

# Set initial tab name on shell startup
if set -q ZELLIJ
    zellij action rename-tab (basename $PWD)
end
