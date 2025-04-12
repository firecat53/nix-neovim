if vim.g.did_load_outline_plugin then
  return
end
vim.g.did_load_outline_plugin = true

require('outline').setup({
  outline_window = {
    auto_close = true,
  },
})
vim.keymap.set('n', '<leader>o', vim.cmd.Outline, { desc = 'Toggle Outline' })
