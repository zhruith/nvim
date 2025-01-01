-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end

-- Setup lazy.nvim
vim.opt.rtp:prepend(lazypath)
-- vim.g.lazy_did_setup = false
require "lazy".setup {
  install = { colorscheme = { "ayu" } },
  checker = { enabled = false },
  spec = {
    { 'neoclide/coc.nvim', branch = "release" },
    {
      'shatur/neovim-ayu',
      config = function()
        require("ayu").setup {
          mirage = false, terminal = false,
          overrides = { NormalFloat = { bg = "black" }, CocHighlightText = { bg = "#1B3A5B" }, } }
        require("ayu").colorscheme()
      end
    },
    {
      'nvim-lualine/lualine.nvim',
      event = "BufReadPost",
      opts = {
        options = {
          theme = function()
            local theme = require('lualine.themes.auto')
            -- theme.normal.c.bg = nil
            return theme
          end,
          globalstatus = true,
          component_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { 'list', '' }, winbar = {} },
          section_separators = {},
        },
        sections = {
          lualine_c = { 'filename', 'g:coc_status' },
          lualine_y = {
            { 'datetime', style = '%H:%M' },
            { 'progress', fmt = function() return "%L" end, },
            'progress',
          },
        }
      }
    },
    {
      'akinsho/toggleterm.nvim',
      cmd = "ToggleTerm",
      opts = {
        persist_mode = false,
        persist_size = true,
        winbar = { enabled = false, },
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          else
            return 20
          end
        end,
      }
    },
    {
      'nvim-treesitter/nvim-treesitter',
      event = "BufReadPost",
      config = function()
        require('nvim-treesitter.configs').setup {
          ensure_installed = {},
          sync_install = false, auto_install = true,
          highlight = { enable = true, additional_vim_regex_highlighting = true, },
        }
      end,
    },
    {
      'akinsho/bufferline.nvim',
      event = "BufReadPost",
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          always_show_bufferline = false,
          offsets = { { filetype = 'NvimTree' }, { filetype = 'netrw' } },
        },
      },
    },
    {
      'nvim-tree/nvim-tree.lua',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      keys = { { "<space>e", "<cmd>NvimTreeToggle<cr>", mode = { "n", "x" } } },
      opts = {
        update_focused_file = { enable = true, update_root = true },
        renderer = { highlight_git = true, root_folder_label = ":t" },
        view = { preserve_window_proportions = true, },
        diagnostics = { enable = true },
        on_attach = function(bufnr)
          local api = require "nvim-tree.api"
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, }
          end
          api.config.mappings.default_on_attach(bufnr)
          for k, v in pairs({
            ["l"] = { api.node.open.edit, opts "Open" },
            ["C"] = { api.tree.change_root_to_node, opts "CD" },
            ["h"] = { api.node.navigate.parent_close, opts "Close Directory" },
          }) do
            vim.keymap.set('n', k, v[1], v[2])
          end
        end,
      },
    },
    {
      'easymotion/vim-easymotion',
      keys = { { "s", "<Plug>(easymotion-bd-w)", mode = "n" } },
      opts = { EasyMotion_do_mapping = 0, EasyMotion_smartcase = 1 }
    },
    {
      'lewis6991/gitsigns.nvim',
      event = "BufReadPost",
      opts = {},
    },
    -- 'puremourning/vimspector',
  },
}
-- global settings
for key, value in pairs({
  wrap = false,
  backup = false,
  writebackup = false,
  hlsearch = false,
  timeout = false,
  ignorecase = true,
  smartcase = true,
  termguicolors = true,
  expandtab = true,
  smartindent = true,
  wildmenu = true,
  updatetime = 100,
  scrolloff = 3,
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  laststatus = 0,
  signcolumn = "yes",
  foldmethod = "manual",
  foldexpr = "",
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
  if vim.fn.index({ "vim", "lua", "help" }, vim.bo.filetype) >= 0 then
    vim.fn.CocActionAsync('doHover')
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. vim.fn.expand('<cword>'))
  end
end

function _G.show_help_docs()
  if vim.fn.index({ "vim", "lua", "help" }, vim.bo.filetype) >= 0 then
    if pcall(function() vim.api.nvim_command('h ' .. vim.fn.expand('<cword>')) end) then
    else
      vim.print('Not exists this help word: ' .. vim.fn.expand('<cword>'))
    end
  end
end

keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', silent)
keyset("n", "<space>K", '<CMD>lua _G.show_help_docs()<CR>', silent)
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
local opts2 = { silent = true, nowait = true }
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts2)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts2)
-- Remap keys for apply code actions at the cursor position.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts2)
-- Remap keys for apply source code actions for current file.
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts2)
-- Apply the most preferred quickfix action on the current line.
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts2)
-- Remap keys for apply refactor code actions.
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", silent)
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", silent)
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", silent)
-- Run the Code Lens actions on the current line
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts2)
-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts2)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts2)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts2)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts2)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts2)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts2)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts2)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts2)
-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset("n", "<C-d>", 'coc#float#has_float() ? coc#float#scroll(1) : "<C-d>"', opts)
keyset("n", "<C-u>", 'coc#float#has_float() ? coc#float#scroll(0) : "<C-u>"', opts)
keyset("i", "<C-d>", 'coc#float#has_float() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-u>", 'coc#float#has_float() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-d>", 'coc#float#has_float() ? coc#float#scroll(1) : "<C-d>"', opts)
keyset("v", "<C-u>", 'coc#float#has_float() ? coc#float#scroll(0) : "<C-u>"', opts)
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
local opts3 = { silent = true, nowait = true, expr = false }
keyset("n", "<space>d", ":CocList diagnostics<cr>", opts3)
keyset("n", "<space>x", ":CocList extensions<cr>", opts3)
keyset("n", "<space>c", ":CocList commands<cr>", opts3)
keyset("n", "<space>o", ":CocCommand session.load<cr>", opts3)
keyset("n", "<space>s", ":CocList outline<cr>", opts3)
keyset("n", "<space>S", ":CocList -I symbols<cr>", opts3)
keyset("n", "<space>j", ":CocNext<cr>", opts3)
keyset("n", "<space>k", ":CocPrev<cr>", opts3)
keyset("n", "<space>p", ":CocListResume<cr>", opts3)
keyset("n", "<space>m", ":CocList marketplace<cr>", opts3)
keyset("n", "<space>b", ":CocList buffers<cr>", opts3)
keyset("n", "<space>f", ":CocList files<cr>", opts3)
keyset("n", "<space>l", ":CocList<cr>", opts3)
keyset("n", "<space>g", ":CocList grep<cr>", opts3)
keyset("n", "<space>r", ":CocList mru<cr>", opts3)
keyset("n", "<space>v", ":CocList vimcommands<cr>", opts3)
keyset("n", "<space>U", ":CocUpdate<cr>", opts3)
keyset("n", "<space>L", ":Lazy<cr>", opts3)

-- g keyshot
keyset("n", "gn", ":bn<cr>", opts3)
keyset("n", "gp", ":bp<cr>", opts3)
keyset("n", "gq", ":bd%<cr>", opts3)
keyset("n", "gQ", ":%bd!|e#|bd#<cr>", opts3)
keyset("n", "ga", ":e#<cr>", opts3)
keyset("n", "gw", "<Plug>(coc-float-jump)", opts3)
keyset({ "n", "x" }, "gh", "0", opts3)
keyset({ "n", "x" }, "gs", "^", opts3)
keyset({ "n", "x" }, "gl", "$", opts3)
keyset("n", "gc", "M", opts3)
keyset("n", "ge", "G", opts3)
-- misc keyshot
keyset("n", "?", ":CocList words<cr>", opts3)
keyset("n", "<Tab>", ":BufferLinePick<cr>", opts3)
keyset("n", "<S-A-f>", ":CocCommand editor.action.formatDocument<cr>", opts3)
keyset("n", "<S-A-c>", ":e $MYVIMRC<cr>", opts3)
keyset("n", "<S-A-r>", ":luafile %<cr>", opts3)
keyset({ "n", "x", "i" }, "<C-s>", "<Esc>:w<cr>", silent)
keyset("n", "<M-h>", function() vim.fn.CocActionAsync('highlight') end, opts3)
keyset("n", "(", ":CocCommand document.jumpToNextSymbol<cr>", opts3)
keyset("n", ")", ":CocCommand document.jumpToPrevSymbol<cr>", opts3)
-- moving cursor
keyset("n", "<C-h>", "<C-w>h", opts3)
keyset("n", "<C-l>", "<C-w>l", opts3)
keyset("n", "<C-j>", "<C-w>j", opts3)
keyset("n", "<C-k>", "<C-w>k", opts3)
keyset({ "i", "t" }, "<C-h>", "<C-\\><C-n><C-w>h", opts3)
keyset({ "i", "t" }, "<C-l>", "<C-\\><C-n><C-w>l", opts3)
keyset({ "i", "t" }, "<C-j>", "<C-\\><C-n><C-w>j", opts3)
keyset({ "i", "t" }, "<C-k>", "<C-\\><C-n><C-w>k", opts3)
keyset("t", "<C-v>", '<C-\\><C-n>"0pa', opts3)
keyset("t", "<C-q>", "<C-\\><C-n>", opts3)
-- moving lines
keyset("n", "<M-j>", ":m .+1<cr>", opts3)
keyset("n", "<M-k>", ":m .-2<cr>", opts3)
keyset("i", "<M-j>", "<Esc>:m .+1<cr>a", opts3)
keyset("i", "<M-k>", "<Esc>:m .-2<cr>a", opts3)
keyset("v", "<M-j>", ":m '>+1<cr>gv-gv", opts3)
keyset("v", "<M-k>", ":m '<-2<cr>gv-gv", opts3)
keyset("v", "<", "<gv", opts3)
keyset("v", ">", ">gv", opts3)
-- resize window
keyset("n", "<S-M-h>", ":vertical resize -2<cr>", opts3)
keyset("n", "<S-M-l>", ":vertical resize +2<cr>", opts3)
keyset("n", "<S-M-j>", ":resize -2<cr>", opts3)
keyset("n", "<S-M-k>", ":resize +2<cr>", opts3)
keyset({ "i", "t" }, "<S-M-h>", "<C-\\><C-n>:vertical resize -2<cr>a", opts3)
keyset({ "i", "t" }, "<S-M-l>", "<C-\\><C-n>:vertical resize +2<cr>a", opts3)
keyset({ "i", "t" }, "<S-M-j>", "<C-\\><C-n>:resize -2<cr>a", opts3)
keyset({ "i", "t" }, "<S-M-k>", "<C-\\><C-n>:resize +2<cr>a", opts3)

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

keyset({ "n", "i", "t" }, "<M-+>", function() terminal_create('vsplit | wincmd l') end, opts3)
keyset({ "n", "i", "t" }, "<M-_>", function() terminal_create('split | wincmd j') end, opts3)

-- set terminal
vim.cmd([[nnoremap <silent><M-1> <Cmd>exe v:count . "ToggleTerm direction=horizontal"<CR>]])
vim.cmd([[nnoremap <silent><M-2> <Cmd>exe v:count . "ToggleTerm direction=vertical"<CR>]])
vim.cmd([[nnoremap <silent><M-3> <Cmd>exe v:count . "ToggleTerm direction=float"<CR>]])
vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "term://*toggleterm#*",
  callback = function()
    keyset("t", "<M-1>", string.format('<Cmd>exe %d . "ToggleTerm"<CR>', vim.v.count), opts3)
    keyset("t", "<M-2>", string.format('<Cmd>exe %d . "ToggleTerm"<CR>', vim.v.count), opts3)
    keyset("t", "<M-3>", string.format('<Cmd>exe %d . "ToggleTerm"<CR>', vim.v.count), opts3)
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

-- Normal = { bg = "" },
-- SignColumn = { bg = "" },
-- WinSeparator = { fg = ayu.ui, bg = "" },
-- Visual = { bg = ayu.selection_border },
-- CursorLine = { bg = lightBlue },
-- CursorLineNr = { bg = lightBlue },
-- Search = { bg = ayu.ui },
-- --Comment = gray,
-- LineNr = { fg = ayu.comment },
-- NonText = gray,
-- DiagnosticHint = gray,
-- SpecialKey = gray,
-- NvimTreeIndentMarker = gray,
-- Folded = { fg = 'lightgray', bg = "" },
