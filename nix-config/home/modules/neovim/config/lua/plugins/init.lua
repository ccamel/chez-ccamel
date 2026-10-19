return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = false,
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", desc = "Git file history" },
    },
    opts = {
      view = {
        default = { layout = "diff2_horizontal" },
        file_history = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal" },
      },
    },
  },

  {
    "NeogitOrg/neogit",
    dependencies = { "folke/snacks.nvim", "sindrets/diffview.nvim" },
    opts = {
      diff_viewer = "diffview",
      integrations = { diffview = true },
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git status" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {
      file_types = { "markdown" },
      heading = {
        sign = false,
        icons = { "▌ ", "▌▌ ", "▌▌▌ ", "▌▌▌▌ ", "▌▌▌▌▌ ", "▌▌▌▌▌▌ " },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
        language_pad = 1,
        border = "thick",
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      latex = { enabled = false },
    },
    config = function(_, opts)
      local render_markdown = require("render-markdown")
      render_markdown.setup(opts)
      require("snacks")
        .toggle({
          name = "Render Markdown",
          get = render_markdown.get,
          set = render_markdown.set,
        })
        :map("<leader>um")
    end,
  },
}
