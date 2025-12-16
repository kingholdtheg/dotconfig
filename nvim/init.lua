local function get_os_appearance()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result:match("Dark") and 'dark' or 'light'
end

local function set_background_from_os()
  local appearance = get_os_appearance()
  if vim.o.background ~= appearance then
    vim.o.background = appearance
  end
end


vim.cmd.colorscheme 'solarized'                                              -- set colorscheme to solarized
vim.g.mapleader = ' '                                                        -- set global map <Leader> to <Space>
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })                       -- jk escapes insert mode
vim.keymap.set('n', '<Leader>qa', ':qa<CR>', { noremap = true })             -- leader+qa quits all buffers
vim.keymap.set('n', '<Leader>qq', ':q<CR>', { noremap = true })              -- leader+qq quits buffer
vim.keymap.set('n', '<Leader>wa', ':wa<CR>', { noremap = true })             -- leader+wa writes all buffers
vim.keymap.set('n', '<Leader>ww', ':w<CR>', { noremap = true })              -- leader+ww writes buffer
vim.o.colorcolumn = "100"                                                    -- color the 100th column
vim.o.expandtab = true                                                       -- <Tab> inserts spaces instead of tabs
vim.o.number = true                                                          -- enable line numbers
vim.o.relativenumber = true                                                  -- line numbers are relative to cursor
vim.o.scrolloff = 8                                                          -- keep 8 lines above or below the cursor
vim.o.shiftwidth = 2                                                         -- (in|de)dent 2 characters
vim.o.signcolumn = "yes"                                                     -- always render a sign column
vim.o.softtabstop = 2                                                        -- <Tab> inserts two charcters
vim.o.tabstop = 2                                                            -- render tabs as 2 characters wide
vim.o.wrap = false                                                           -- disable line wrap
vim.uv.new_timer():start(0, 2000, vim.schedule_wrap(set_background_from_os)) -- update background from os every two seconds

-- set initial background and colorscheme
set_background_from_os()

-- import lspconfig
local lspconfig = require('lspconfig')

-- setup lua_ls
lspconfig.lua_ls.setup({
  on_attach = function(client, bufnr)
    -- setup format on save
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
  -- configure lua ls
  settings = {
    Lua = {
      ["format.defaultConfig.max_line_length"] = 'unset', -- disable max line length
      ["diagnostics.globals"] = { "vim" },                -- register global variables "vim"
    },
  }
})

vim.lsp.enable("lua_ls") -- enable the lua_ls lsp server

-- setup nvim-tree
local tree = require("nvim-tree")
tree.setup({
  on_attach = function(bufnr)
    local api = require("nvim-tree.api") -- nvim-tree's api

    -- getter for keymap options
    local function opts(desc) return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true } end

    -- set default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- set custom mappings
    vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  end
})
