-- Set up vimwiki global variables first
vim.g.vimwiki_list = {{
  path = '~/docs/family/scott/wiki',
  ext = '.md',
  syntax = 'markdown',
  index = 'Home',
  diary_rel_path = os.date('diary/%Y')
}}
vim.g.vimwiki_auto_chdir = 1
vim.g.vimwiki_folding = ""
vim.g.vimwiki_global_ext = 0

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local wiki_path = vim.fn.expand('~/docs/family/scott/wiki')
    vim.loop.chdir(wiki_path)

    local handle = vim.loop.spawn('git', {
      args = {'status'},
      cwd = wiki_path
    }, function(code, signal)
      if code == 0 then
        local handle2 = vim.loop.spawn('git', {
          args = {'add', '.'},
          cwd = wiki_path
        }, function(code2, signal2)
          if code2 == 0 then
            local commit_msg = string.format('Update: %s', os.date('%Y-%m-%d %H:%M:%S'))
            vim.loop.spawn('git', {
              args = {'commit', '-m', commit_msg},
              cwd = wiki_path
            })
          end
        end)
      end
    end)
  end,
  group = vim.api.nvim_create_augroup("VimwikiGit", { clear = true })
})

-- Map <Leader>j and <Leader>k for Vimwiki diary navigation
vim.api.nvim_set_keymap('n', '<Leader>j', '<Plug>VimwikiDiaryNextDay', {})
vim.api.nvim_set_keymap('n', '<Leader>k', '<Plug>VimwikiDiaryPrevDay', {})
