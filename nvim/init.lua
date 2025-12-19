--- Get light or dark appearance from OS.
---
--- If an appearance cannot be gotten, light is returned.
---
--- @return "light"|"dark"
local function get_os_appearance()
  -- open MacOS dark/light theme preference as a file
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if handle == nil then
    return "light" -- failed to open file, default to light
  end

  -- read the file
  local result = handle:read("*a")

  -- close the file's handle
  handle:close()

  -- return 'dark' or 'light' depending on theme preferenc
  return result:match("Dark") and "dark" or "light"
end

--- Sets vim's background from the OS's preferred appearance.
local function set_background_from_os()
  -- the OS' preferred appearance
  local appearance = get_os_appearance()

  -- if vim's background is already the OS's preferred appearance, return
  if vim.o.background == appearance then
    return
  end

  -- set vim's background to OS's preferred ap
  vim.o.background = appearance
end


vim.cmd.colorscheme("solarized")                                             -- set colorscheme to solarized
vim.g.mapleader = " "                                                        -- set global map <Leader> to <Space>
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })                       -- jk escapes insert mode
vim.keymap.set("n", "<Leader>qa", ":qa<CR>", { noremap = true })             -- leader+qa quits all buffers
vim.keymap.set("n", "<Leader>qq", ":q<CR>", { noremap = true })              -- leader+qq quits buffer
vim.keymap.set("n", "<Leader>wa", ":wa<CR>", { noremap = true })             -- leader+wa writes all buffers
vim.keymap.set("n", "<Leader>ww", ":w<CR>", { noremap = true })              -- leader+ww writes buffer
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

-- configure lua-language-server
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      format = {
        defaultConfig = {
          call_arg_parentheses = "always", -- always surround call args with parentheses
          quote_style = "double"           -- always express string literals with double quotes
        }
      },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) }
    }
  }
})

-- enable lua-language-server
vim.lsp.enable("lua_ls")

-- format on save if lsp supports it
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client:supports_method("textDocument/formatting") then
        vim.lsp.buf.format({ bufnr = 0 })
        return
      end
    end
  end
})

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
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
  end
})
