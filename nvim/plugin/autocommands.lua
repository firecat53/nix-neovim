if vim.g.did_load_autocommands_plugin then
  return
end
vim.g.did_load_autocommands_plugin = true

local api = vim.api

local tempdirgroup = api.nvim_create_augroup('tempdir', { clear = true })
-- Do not set undofile for files in /tmp
api.nvim_create_autocmd('BufWritePre', {
  pattern = '/tmp/*',
  group = tempdirgroup,
  callback = function()
    vim.cmd.setlocal('noundofile')
  end,
})

-- Disable spell checking in terminal buffers
local nospell_group = api.nvim_create_augroup('nospell', { clear = true })
api.nvim_create_autocmd('TermOpen', {
  group = nospell_group,
  callback = function()
    vim.wo[0].spell = false
  end,
})

-- LSP
local keymap = vim.keymap

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        -- Navigate between markdown links with Tab
        vim.keymap.set('n', '<Tab>', '/\\(\\[\\[\\|\\[.\\{-}\\](\\)<CR>:nohlsearch<CR>', { buffer = true })
        vim.keymap.set('n', '<S-Tab>', '?\\(\\[\\[\\|\\[.\\{-}\\](\\)<CR>:nohlsearch<CR>', { buffer = true })

        -- Proper list indentation
        vim.opt_local.formatlistpat = [[^\s*\d\+[\]:.)}\t ]\s*\|^\s*[-*+]\s\+]]
        vim.opt_local.autoindent = true
        vim.opt_local.formatoptions:append('ncro')
    end
})

-- LSP options and keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Only attach navic if server supports documentSymbols
    if client and client.server_capabilities.documentSymbolProvider then
      require('nvim-navic').attach(client, bufnr)
    end

    vim.cmd.setlocal('signcolumn=yes')
    vim.bo[bufnr].bufhidden = 'hide'

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local function desc(description)
      return { noremap = true, silent = true, buffer = bufnr, desc = description }
    end
    keymap.set('n', 'gD', vim.lsp.buf.declaration, desc('lsp [g]o to [D]eclaration'))
    keymap.set('n', 'gd', vim.lsp.buf.definition, desc('lsp [g]o to [d]efinition'))
    keymap.set('n', 'gr', vim.lsp.buf.references, desc('lsp [g]et [r]eferences'))
    keymap.set('n', 'K', vim.lsp.buf.hover, desc('[lsp] hover'))
    keymap.set('n', '<leader>rn', vim.lsp.buf.rename, desc('lsp [r]e[n]ame'))
    keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, desc('lsp [c]ode [a]ction'))
    keymap.set('n', '<leader>cl', vim.lsp.codelens.run, desc('lsp run [c]ode [l]ens'))
    keymap.set('n', '<leader>cr', vim.lsp.codelens.refresh, desc('lsp [c]ode lenses [r]efresh'))
    keymap.set('n', '<localleader>f', function()
      vim.lsp.buf.format { async = true }
    end, desc('lsp [f]ormat buffer'))
    if client and client.server_capabilities.inlayHintProvider then
      keymap.set('n', '<localleader>h', function()
        local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
      end, desc('lsp toggle inlay [h]ints'))
    end

    -- Auto-refresh code lenses
    if not client then
      return
    end
    local group = api.nvim_create_augroup(string.format('lsp-%s-%s', bufnr, client.id), {})
    if client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost', 'TextChanged' }, {
        group = group,
        callback = function()
          vim.lsp.codelens.refresh { bufnr = bufnr }
        end,
        buffer = bufnr,
      })
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end
  end,
})

-- Autosave when leaving buffers
vim.api.nvim_create_autocmd({ "BufLeave", "BufUnload" }, {
  pattern = "*",
  command = "silent! w!"
})
