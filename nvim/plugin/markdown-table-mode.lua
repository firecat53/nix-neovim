require('markdown-table-mode').setup({
  filetype = {
    '*.md',
  },
  options = {
    insert = true, -- when typing "|"
    insert_leave = true, -- when leaving insert
    pad_separator_line = false, -- add space in separator line
    align_style = 'default', -- default, left, center, right
  },
})

vim.keymap.set('n', '<leader>ft', vim.cmd.Mtm, { desc = 'Toggle [f]ormat [t]able Mode' })
