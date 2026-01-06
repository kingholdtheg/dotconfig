# Auto-rename zellij tabs based on running command
# Renames tab to command while running, resets to directory name when done

function __zellij_rename_tab_to_dir
    if test $PWD = $HOME
        zellij action rename-tab '~'
    else
        zellij action rename-tab (basename $PWD)
    end
end

function zellij_tab_name_update_preexec --on-event fish_preexec
    if set -q ZELLIJ
        # Get just the command name (first word)
        set -l cmd (string split ' ' -- $argv[1])[1]
        __zellij_rename_tab_to_dir
    end
end

function zellij_tab_name_update_postexec --on-event fish_postexec
    if set -q ZELLIJ
        __zellij_rename_tab_to_dir
    end
end

function zellij_tab_name_update_pwd --on-variable PWD
    if set -q ZELLIJ
        # Only update if no command is actively running
        __zellij_rename_tab_to_dir
    end
end

# Set initial tab name on shell startup
if set -q ZELLIJ
    __zellij_rename_tab_to_dir
end
