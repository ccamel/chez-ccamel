-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Terminal & Vi-mode consistency

vim.opt.shell = "zsh"
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WSL",
    copy = {
      ["+"] = { "clip.exe" },
      ["*"] = { "clip.exe" },
    },
    paste = {
      ["+"] = {
        "powershell.exe",
        "-NoProfile",
        "-NoLogo",
        "-Command",
        "[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Get-Clipboard",
      },
      ["*"] = {
        "powershell.exe",
        "-NoProfile",
        "-NoLogo",
        "-Command",
        "[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Get-Clipboard",
      },
    },
    cache_enabled = 0,
  }
end
