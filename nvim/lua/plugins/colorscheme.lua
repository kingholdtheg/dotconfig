return {
  -- Add Solarized colorscheme
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized").setup({ transparent = { enabled = false } })

      -- Sync background with system appearance on macOS
      local last_check_time = nil
      local check_interval = 3000
      local cached_appearance = nil

      local function sync_background()
        if vim.fn.has("mac") == 0 then
          return
        end

        if cached_appearance ~= nil and last_check_time and (vim.loop.now() - last_check_time < check_interval) then
          vim.o.background = cached_appearance and "dark" or "light"
          return
        end

        local current_time = vim.loop.now()

        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()

          local is_dark = result and result:match("Dark") ~= nil or false
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
