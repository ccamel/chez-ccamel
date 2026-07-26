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
