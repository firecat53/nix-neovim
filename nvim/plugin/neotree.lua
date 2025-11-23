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
      ["\\"] = function(state)
        local node = state.tree:get_node()
        local path = node:get_id()
        -- If it's a file, use its parent directory
        if node.type ~= "directory" then
          path = vim.fn.fnamemodify(path, ":h")
        end
        require("telescope.builtin").live_grep({
          cwd = path,
          prompt_title = "Live Grep in " .. vim.fn.fnamemodify(path, ":~:."),
        })
      end,
    }
  }
})

-- Toggle file explorer
vim.keymap.set('n', '<leader>F', function()
  vim.cmd.Neotree('toggle', 'current', 'reveal_force_cwd', 'float')
end, { silent = true, desc = "Toggle Neotree [file] explorer" })
