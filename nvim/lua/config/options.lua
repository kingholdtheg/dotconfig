-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Configure Neovim's Python virtual environment
vim.g.python3_host_prog = "~/.config/nvim/.venv/bin/python"

-- Configure Python LSP
vim.g.lazyvim_python_lsp = "ty"
