-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Delete word backwards with Ctrl+Backspace
vim.keymap.set("i", "<C-h>", "<C-w>", { desc = "Delete word backwards" })

-- Delete word forwards with Ctrl+Delete
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { desc = "Delete word forwards" })
