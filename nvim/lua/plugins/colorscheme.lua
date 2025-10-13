return {
  -- Add Solarized colorscheme
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized").setup({ transparent = { enabled = false } })

      -- Sync background with system appearance on macOS
      local function sync_background()
        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result:match("Dark") then
            vim.o.background = "dark"
          else
            vim.o.background = "light"
          end
        end
      end

      -- Set initial background
      sync_background()

      -- Create an autocmd to check for system appearance changes periodically
      vim.api.nvim_create_autocmd({ "FocusGained", "VimEnter" }, {
        callback = sync_background,
        desc = "Sync background with system appearance",
      })
    end,
  },
  -- Configure LazyVim to load Solarized
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "solarized" },
  },
}
