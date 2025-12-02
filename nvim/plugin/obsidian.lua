vim.opt.conceallevel = 2
local wiki_path = vim.fn.expand("~/docs/family/scott/wiki")

require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "wiki",
      path = wiki_path,
    },
    {
      name = "no-vault",
      path = function()
        return assert(vim.fn.getcwd())
      end,
      ---@diagnostic disable-next-line: missing-fields
      overrides = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
        new_notes_location = "current_dir",
        daily_notes = {
          ---@diagnostic disable-next-line: assign-type-mismatch
          folder = vim.NIL,
        },
        templates = {
          ---@diagnostic disable-next-line: assign-type-mismatch
          folder = vim.NIL,
        },
        frontmatter = { enabled = false },
      },
    },
  },
  daily_notes = {
    folder = "diary/" .. os.date("%Y"),
  },
  new_notes_location = "current_dir",
  preferred_link_style = "wiki",
  frontmatter = { enabled = false },
  follow_url_func = function(url)
    -- Open the URL in the default web browser.
    vim.ui.open(url) -- need Neovim 0.10.0+
  end
})

-- Keymaps
vim.keymap.set('n', '<leader>ww', function()
  vim.cmd('Obsidian workspace wiki')
  vim.cmd('Obsidian quick_switch Home')
end)

vim.keymap.set('n', '<leader>w<leader>w', function()
  vim.cmd('Obsidian workspace wiki')
  vim.cmd('Obsidian today')
end)

-- Replicate Vimwiki <leader>j <leader>k to move between diary days
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*/diary/*/????-??-??.md",
  callback = function()
    local function goto_adjacent_day(offset)
      local current_file = vim.fn.expand('%:t:r') -- Get filename without extension

      local date = os.time({
        year = assert(tonumber(current_file:sub(1, 4))),
        month = assert(tonumber(current_file:sub(6, 7))),
        day = assert(tonumber(current_file:sub(9, 10)))
      })
      local new_date = date + (offset * 86400)
      local new_file = os.date('%Y-%m-%d', new_date) .. '.md'
      local new_path = vim.fn.expand('%:p:h') .. '/' .. new_file
      vim.cmd('bdelete!')
      vim.cmd('edit ' .. new_path)
      -- If it's a new file, add any template content you want here
      if vim.fn.filereadable(new_path) == 0 then
        vim.cmd('write')
      end
    end

    vim.keymap.set('n', '<leader>j', function() goto_adjacent_day(1) end, { buffer = true, desc = 'Obsidian Next Day' })
    vim.keymap.set('n', '<leader>k', function() goto_adjacent_day(-1) end, { buffer = true, desc = 'Obsidian Prev Day' })
  end
})

-- Git commit changes to Wiki when exiting neovim.

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    -- Change to wiki directory temporarily
    local current_dir = vim.fn.getcwd()
    vim.cmd('cd ' .. wiki_path)

    -- Check if there are any changes in the wiki directory
    local git_status = vim.fn.system('git status --porcelain')

    if git_status ~= "" then
      -- There are changes to commit
      local timestamp = os.date("%Y-%m-%d %H:%M:%S")
      local commit_msg = string.format("Update: %s", timestamp)

      -- Try to add and commit changes
      local success = true
      local error_msg = ""

      -- Add all changes (including new files)
      local add_result = vim.fn.system('git add -A 2>&1')
      if vim.v.shell_error ~= 0 then
        success = false
        error_msg = "Git add failed: " .. add_result
      end

      -- Commit if add was successful
      if success then
        local commit_result = vim.fn.system('git commit -m "' .. commit_msg .. '" 2>&1')
        if vim.v.shell_error ~= 0 then
          success = false
          error_msg = "Git commit failed: " .. commit_result
        end
      end

      -- Return to original directory
      vim.cmd('cd ' .. current_dir)

      -- Show error and prevent exit if there was a problem
      if not success then
        error("Wiki git operations failed: " .. error_msg)
      end
    else
      -- No changes, just return to original directory
      vim.cmd('cd ' .. current_dir)
    end
  end
})
