# disable greeting
set -U fish_greeting

# setup brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# setup rustup
if command -v rustup &>/dev/null
    fish_add_path --global --move --path --prepend $HOMEBREW_PREFIX/opt/rustup/bin
    fish_add_path --global --move --path --prepend $HOMEBREW_PREFIX/opt/rustup/sbin
end

# setup pyenv
if command -v pyenv &>/dev/null
    pyenv init - fish | source
end

# setup go
if command -v go &>/dev/null
    fish_add_path --global --move --prepend "$(go env GOPATH)/bin"
end

# setup ghcup
if command -v ghcup &>/dev/null
    fish_add_path --global --move --prepend "$(ghcup whereis bindir)"
end

# setup dotnet@8
if test -d /opt/homebrew/opt/dotnet@8/bin/ &>/dev/null
    fish_add_path --global --move --prepend "/opt/homebrew/opt/dotnet@8/bin/"
end

# setup rancher desktop
if test -d ~/.rd/bin/
    fish_add_path --global --move --prepend ~/.rd/bin
end

if status is-interactive
    # Commands to run in interactive sessions can go here

    # zellij tab auto-naming
    source (dirname (status filename))/functions/zellij_tab_name.fish

    # aliases
    alias lg lazygit
    alias ld lazydocker
    alias j just
    alias n nvim

    # environment variables
    set -gx ZELLIJ_AUTO_EXIT true # When zellij exits, the shell exits as well.
    set -gx EDITOR nvim # set default editor to neovim

    # if the interactive terminal is Wezterm, start zelli
    if [ "$TERM_PROGRAM" = WezTerm ]
        eval (zellij setup --generate-auto-start fish | string collect) # start zellij
    end
end
