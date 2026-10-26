return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = false,
      },
      image = {
        enabled = vim.env.TERM_PROGRAM == "ghostty",
      },
    },
  },
  {
    "3rd/image.nvim",
    build = false,
    cond = function()
      return vim.env.WT_SESSION ~= nil and vim.env.TERM_PROGRAM ~= "herdr"
    end,
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = "popup",
        },
      },
    },
  },
  {
    "hmdfrds/focal.nvim",
    cond = function()
      return vim.env.TERM_PROGRAM == "herdr"
    end,
    config = function(_, opts)
      local focal = require("focal")
      focal.register_source({
        filetype = "markdown",
        get_path = function()
          local target = vim.fn.expand("<cfile>")
          if target == "" or target:find("://", 1, true) then
            return nil
          end

          -- shortcut: local Markdown links only; use a Markdown parser if remote images are needed.
          local path = target:sub(1, 1) == "/" and target or vim.fn.expand("%:p:h") .. "/" .. target
          return vim.fn.filereadable(path) == 1 and path or nil
        end,
      })
      focal.setup(opts)
    end,
    opts = {
      backend = "chafa",
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
