return {
  -- Add Solarized colorscheme
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- setup solarized
      require("solarized").setup({ transparent = { enabled = false } })

      --- sync_background sets vim's background option to match the OS' preferred appearance.
      ---
      --- If the OS' preference cannot be determined, the background will default to 'light'
      local function sync_background()
        local background = "light"
        local file = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if file then
          local preference = file:read("*a")
          file:close()
          if preference:match("Dark") then
            background = "dark"
          end
        end
        vim.o.background = background
      end

      -- Set initial background
      sync_background()

      -- Start a timer that periodically (every 10s) syncs the background
      local timer = vim.uv.new_timer()
      if timer then
        timer:start(10000, 10000, vim.schedule_wrap(sync_background))
      end
    end,
  },
  -- Configure LazyVim to load Solarized
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "solarized" },
  },
}
