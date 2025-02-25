if vim.g.did_load_neotree_plugin then
  return
end
vim.g.did_load_neotree_plugin = true

require("neo-tree").setup({
  window = {
    mappings = {
      ["<bs>"] = "close_window",
      ["l"] = { "open", nowait = true },
      ["h"] = "navigate_up",
    }
  }
})

-- Toggle file explorer
vim.keymap.set('n', '<leader>F', function()
  vim.cmd.Neotree('toggle', 'current', 'reveal_force_cwd', 'float')
end, { silent = true, desc = "Toggle Neotree [file] explorer" })
