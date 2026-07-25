return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "darker",
      colors = {
        bg0 = "#000000",
      },
    },
    config = function(_, opts)
      require("onedark").setup(opts)
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("onedark").load()
      end,
    },
  },
}
