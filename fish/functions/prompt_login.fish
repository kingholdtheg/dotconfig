function prompt_login --description 'display user name for the prompt'
    echo -n -s (set_color $fish_color_user) "kin!" (set_color normal) @ (set_color $fish_color_host) (prompt_hostname) (set_color normal)
end
