return {
  -- Add Solarized colorscheme
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized").setup({ transparent = { enabled = false } })

      -- Sync background with system appearance on macOS
      local last_check_time = 0
      local check_interval = 5000
      local cached_appearance = nil

      local function sync_background()
        local current_time = vim.loop.now()
        
        if current_time - last_check_time < check_interval and cached_appearance ~= nil then
          return
        end

        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          
          local is_dark = result:match("Dark") ~= nil
          cached_appearance = is_dark
          last_check_time = current_time
          
          if is_dark then
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
