-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
-- Setup lazy.nvim
vim.g.lazy_did_setup = false
require("lazy").setup({
  spec = {
    { 'neoclide/coc.nvim', branch = "release" },
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-tree.lua',
    'nvim-lualine/lualine.nvim',
    'nvim-tree/nvim-web-devicons',
    'akinsho/bufferline.nvim',
    'akinsho/toggleterm.nvim',
    'shatur/neovim-ayu',
    'lewis6991/gitsigns.nvim',
    'easymotion/vim-easymotion',
    -- 'puremourning/vimspector',
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "ayu" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
-- global settings
for key, value in pairs({
  backup = false,
  writebackup = false,
  updatetime = 150,
  signcolumn = "yes",
  hlsearch = false,
  scrolloff = 3,
  timeout = false,
  ignorecase = true,
  smartcase = true,
  wrap = false,
  termguicolors = true,
  foldmethod = "manual",
  foldexpr = "",
  expandtab = true,
  smartindent = true,
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  wildmenu = true,
  wildmode = "list:longest,full",
  wildignore = "*.dll,*.exe,*.jpg,*.gif,*.png",
}) do
  vim.opt[key] = value
end
-- hard to batch settings
vim.cmd('filetype indent plugin on')
vim.cmd('set fillchars+=eob:\\ ')
vim.cmd('set shell=nu')
vim.o.shellcmdflag = '-c '
vim.cmd('set shellxquote= shellxquote=')
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1

require "conf" -- loading other plugs setting

-- coc.nvim default settings
local keyset = vim.keymap.set
local silent = { silent = true }
-- Autocomplete
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })
-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "[d", "<Plug>(coc-diagnostic-next)", silent)
keyset("n", "]d", "<Plug>(coc-diagnostic-prev)", silent)
-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", silent)
keyset("n", "gy", "<Plug>(coc-type-definition)", silent)
keyset("n", "gi", "<Plug>(coc-implementation)", silent)
keyset("n", "gr", "<Plug>(coc-references)", silent)
-- Use K to show documentation in preview window
function _G.show_docs()
  local cw = vim.fn.expand('<cword>')
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command('h ' .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
  end
end

keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', silent)
-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
vim.api.nvim_create_augroup("CocGroup", {})
-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	group = "CocGroup",
-- 	command = "silent call CocActionAsync('highlight')",
-- 	desc = "Highlight symbol under cursor on CursorHold"
-- })
-- Symbol renaming
keyset("n", "<leader>rn", "<Plug>(coc-rename)", silent)
-- Formatting selected code
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", silent)
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", silent)
-- Setup formatexpr specified filetype(s)
vim.api.nvim_create_autocmd("FileType", {
  group = "CocGroup",
  pattern = "typescript,json",
  command = "setl formatexpr=CocAction('formatSelected')",
  desc = "Setup formatexpr specified filetype(s)."
})
-- Update signature help on jump placeholder
vim.api.nvim_create_autocmd("User", {
  group = "CocGroup",
  pattern = "CocJumpPlaceholder",
  command = "call CocActionAsync('showSignatureHelp')",
  desc = "Update signature help on jump placeholder"
})
-- Apply codeAction to the selected region
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
-- Remap keys for apply code actions at the cursor position.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply source code actions for current file.
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- Apply the most preferred quickfix action on the current line.
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)
-- Remap keys for apply refactor code actions.
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", silent)
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", silent)
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", silent)
-- Run the Code Lens actions on the current line
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)
-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)
-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset("n", "<C-d>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-d>"', opts)
keyset("n", "<C-u>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-u>"', opts)
keyset("i", "<C-d>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-u>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-d>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-d>"', opts)
keyset("v", "<C-u>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-u>"', opts)
-- Use CTRL-S for selections ranges
-- Requires 'textDocument/selectionRange' support of language server
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
-- Add (Neo)Vim's native statusline support
-- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- provide custom statusline: lightline.vim, vim-airline
vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true }
keyset("n", "<space>d", ":CocList diagnostics<cr>", opts)
keyset("n", "<space>x", ":CocList extensions<cr>", opts)
keyset("n", "<space>c", ":CocList commands<cr>", opts)
keyset("n", "<space>o", ":CocCommand session.load<cr>", opts)
keyset("n", "<space>s", ":CocList outline<cr>", opts)
keyset("n", "<space>S", ":CocList -I symbols<cr>", opts)
keyset("n", "<space>j", ":CocNext<cr>", opts)
keyset("n", "<space>k", ":CocPrev<cr>", opts)
keyset("n", "<space>p", ":CocListResume<cr>", opts)
keyset("n", "<space>m", ":CocList marketplace<cr>", opts)
keyset("n", "<space>b", ":CocList buffers<cr>", opts)
keyset("n", "<space>e", ":NvimTreeToggle<cr>", opts)
keyset("n", "<space>f", ":CocList files<cr>", opts)
keyset("n", "<space>l", ":CocList<cr>", opts)
keyset("n", "<space>g", ":CocList grep<cr>", opts)
keyset("n", "<space>w", ":CocList words<cr>", opts)
keyset("n", "<space>r", ":CocList mru<cr>", opts)
keyset("n", "<space>v", ":CocList vimcommands<cr>", opts)
keyset("n", "<space>U", ":CocUpdate<cr>", opts)
keyset("n", "<space>L", ":Lazy<cr>", opts)
-- g keyshot

keyset("n", "gn", ":bn<cr>", opts)
keyset("n", "gp", ":bp<cr>", opts)
keyset("n", "gq", ":bd%<cr>", opts)
keyset("n", "gQ", ":%bd!|e#|bd#<cr>", opts)
keyset("n", "ga", ":e#<cr>", opts)
keyset("n", "gw", "<Plug>(coc-float-jump)", opts)
keyset("n", "gh", "0", opts)
keyset("n", "gs", "^", opts)
keyset("n", "gl", "$", opts)
keyset("n", "gc", "M", opts)
keyset("n", "ge", "G", opts)
-- misc keyshot
keyset("n", "s", "<Plug>(easymotion-bd-w)", opts)
keyset("n", "<S-A-f>", ":CocCommand editor.action.formatDocument<cr>", opts)
keyset("n", "<S-A-c>", ":e $MYVIMRC<cr>", opts)
keyset("n", "<S-A-r>", ":luafile %<cr>", opts)
keyset("n", "<C-s>", ":w<cr>", silent)
keyset("v", "<C-s>", ":w<cr>", silent)
keyset("i", "<C-s>", "<Esc>:w<cr>", silent)
vim.api.nvim_create_user_command("Highlight", "call CocActionAsync('highlight')", {})
keyset("n", "<M-h>", ":Highlight<cr>", opts)
keyset("n", "(", ":CocCommand document.jumpToNextSymbol<cr>", opts)
keyset("n", ")", ":CocCommand document.jumpToPrevSymbol<cr>", opts)
-- moving cursor
keyset("n", "<C-h>", "<C-w>h")
keyset("n", "<C-l>", "<C-w>l")
keyset("n", "<C-j>", "<C-w>j")
keyset("n", "<C-k>", "<C-w>k")
keyset("i", "<C-h>", "<C-\\><C-n><C-w>h")
keyset("i", "<C-l>", "<C-\\><C-n><C-w>l")
keyset("i", "<C-j>", "<C-\\><C-n><C-w>j")
keyset("i", "<C-k>", "<C-\\><C-n><C-w>k")
keyset("t", "<C-h>", "<C-\\><C-n><C-w>h")
keyset("t", "<C-l>", "<C-\\><C-n><C-w>l")
keyset("t", "<C-j>", "<C-\\><C-n><C-w>j")
keyset("t", "<C-k>", "<C-\\><C-n><C-w>k")
keyset("t", "<C-v>", '<C-\\><C-n>"0pa')
keyset("t", "<C-q>", "<C-\\><C-n>")
-- moving lines
keyset("n", "<M-j>", ":m .+1<cr>", opts)
keyset("n", "<M-k>", ":m .-2<cr>", opts)
keyset("i", "<M-j>", "<Esc>:m .+1<cr>a", opts)
keyset("i", "<M-k>", "<Esc>:m .-2<cr>a", opts)
keyset("v", "<M-j>", ":m '>+1<cr>gv-gv", opts)
keyset("v", "<M-k>", ":m '<-2<cr>gv-gv", opts)
keyset("v", "<", "<gv", opts)
keyset("v", ">", ">gv", opts)
-- resize window
keyset("n", "<S-M-h>", ":vertical resize -2<cr>", opts)
keyset("n", "<S-M-l>", ":vertical resize +2<cr>", opts)
keyset("n", "<S-M-j>", ":resize -2<cr>", opts)
keyset("n", "<S-M-k>", ":resize +2<cr>", opts)
keyset("i", "<S-M-h>", "<C-\\><C-n>:vertical resize -2<cr>a", opts)
keyset("i", "<S-M-l>", "<C-\\><C-n>:vertical resize +2<cr>a", opts)
keyset("i", "<S-M-j>", "<C-\\><C-n>:resize -2<cr>a", opts)
keyset("i", "<S-M-k>", "<C-\\><C-n>:resize +2<cr>a", opts)
keyset("t", "<S-M-h>", "<C-\\><C-n>:vertical resize -2<cr>a", opts)
keyset("t", "<S-M-l>", "<C-\\><C-n>:vertical resize +2<cr>a", opts)
keyset("t", "<S-M-j>", "<C-\\><C-n>:resize -2<cr>a", opts)
keyset("t", "<S-M-k>", "<C-\\><C-n>:resize +2<cr>a", opts)

local function terminal_create(cmd)
  vim.cmd(string.format('%s | terminal', cmd))
  vim.cmd("startinsert")
  local term_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value('buflisted', false, { buf = term_buf })
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_buf,
    callback = function() vim.cmd("bd" .. term_buf) end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "BufWinEnter" }, {
    buffer = term_buf,
    callback = function() vim.cmd("startinsert") end
  })
end
vim.api.nvim_create_autocmd({ "BufHidden" }, {
  -- pattern = "term://*",
  callback = function()
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
        vim.cmd('startinsert')
      end
    end)
  end
})

keyset("n", "<M-+>", function() terminal_create('vsplit | wincmd l') end, opts)
keyset("n", "<M-_>", function() terminal_create('split | wincmd j') end, opts)
keyset("i", "<M-+>", function() terminal_create('vsplit | wincmd l') end, opts)
keyset("i", "<M-_>", function() terminal_create('split | wincmd j') end, opts)
keyset("t", "<M-+>", function() terminal_create('vsplit | wincmd l') end, opts)
keyset("t", "<M-_>", function() terminal_create('split | wincmd j') end, opts)

-- set terminal
vim.cmd([[nnoremap <silent><M-1> <Cmd>exe v:count . "ToggleTerm direction=horizontal"<CR>]])
vim.cmd([[nnoremap <silent><M-2> <Cmd>exe v:count . "ToggleTerm direction=vertical"<CR>]])
vim.cmd([[nnoremap <silent><M-3> <Cmd>exe v:count . "ToggleTerm direction=float"<CR>]])
vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "term://*toggleterm#*",
  callback = function()
    keyset("t", "<M-1>", string.format('<Cmd>exe %d . "ToggleTerm"<CR>', vim.v.count), opts)
    keyset("t", "<M-2>", string.format('<Cmd>exe %d . "ToggleTerm"<CR>', vim.v.count), opts)
    keyset("t", "<M-3>", string.format('<Cmd>exe %d . "ToggleTerm"<CR>', vim.v.count), opts)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("JsonToJsonc", { clear = true }),
  pattern = "json",
  callback = function() vim.bo.filetype = "jsonc" end,
})
-- auto set cursor to the last position
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = { '*' },
  desc = 'When editing a file, always jump to the last known cursor position',
  callback = function()
    local line = vim.fn.line '\'"'
    if line >= 1
        and line <= vim.fn.line '$'
        and vim.bo.filetype ~= 'commit'
        and vim.fn.index({ 'xxd', 'gitrebase' }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

vim.g.coc_global_extensions = {
  'coc-clangd',
  'coc-cmake',
  'coc-emmet',
  'coc-json',
  'coc-pairs',
  'coc-rust-analyzer',
  'coc-tsserver',
  'coc-toml',
  'coc-marketplace',
  'coc-lists',
  'coc-vimlsp',
  '@yaegassy/coc-pylsp',
  '@yaegassy/coc-volar',
  '@yaegassy/coc-volar-tools',
  'coc-css',
  'coc-html',
  'coc-sumneko-lua',
  'coc-sh',
}
