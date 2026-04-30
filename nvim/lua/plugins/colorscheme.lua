return {
  { "catppuccin/nvim", enabled = false },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("nightfox").setup(opts)
      local style = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null")
      local dark = style == "Dark"
      vim.o.background = dark and "dark" or "light"
      local scheme = dark and "nightfox" or "dayfox"
      vim.cmd.colorscheme(scheme)
    end,
  },
}
