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
    { 'shatur/neovim-ayu',
      config = function()
        local nobg = { bg = '' }
        require("ayu").setup {
          mirage = false, terminal = false,
          overrides = {
            Normal = nobg, SignColumn = nobg, WinSeparator = { fg = "#1B3A5B", bg = "" },
            NormalFloat = { bg = "black" },
          } }
        require("ayu").colorscheme()
      end },
    { 'nvim-lualine/lualine.nvim',
      event = "BufReadPost",
      opts = {
        options = {
          icons_enabled = false,
          theme = function()
            local theme = require('lualine.themes.auto')
            theme.normal.c.bg = nil
            return theme
          end,
          globalstatus = true,
          component_separators = "", -- { left = "", right = "" },
          disabled_filetypes = { statusline = { 'list', '' }, winbar = {} },
          section_separators = {},
        },
        sections = {
          lualine_a = {
            { 'mode', fmt = function(str) return str:sub(1, 3) end }
          },
          lualine_c = {
            function() return require('auto-session.lib').current_session_name(true) end,
            'filename',
          },
          lualine_x = { { 'datetime', style = '%H:%M:%S' }, },
          lualine_y = { 'fileformat', 'filetype',
            { 'progress', fmt = function() return "%L" end, },
            'progress' },
        }
      } },
    { 'akinsho/toggleterm.nvim',
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
      } },
    { 'nvim-treesitter/nvim-treesitter',
      event = "BufReadPost",
      config = function()
        require('nvim-treesitter.configs').setup {
          ensure_installed = {},
          sync_install = false, auto_install = true,
          highlight = { enable = true, additional_vim_regex_highlighting = true, },
        }
      end },
    { 'akinsho/bufferline.nvim',
      event = "BufReadPost",
      -- dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          always_show_bufferline = false,
          show_buffer_close_icons = false,
          offsets = { { filetype = 'NvimTree' }, { filetype = 'netrw' } },
        },
      } },
    { 'nvim-tree/nvim-tree.lua',
      -- dependencies = { 'nvim-tree/nvim-web-devicons' },
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
        end } },
    { 'easymotion/vim-easymotion',
      keys = { { "<space>s", "<Plug>(easymotion-overwin-w)", mode = "n" } },
      opts = { EasyMotion_do_mapping = 0, EasyMotion_smartcase = 1 }
    },
    { 'lewis6991/gitsigns.nvim',
      event = "BufReadPost",
      opts = {},
    },
    { "lukas-reineke/indent-blankline.nvim",
      event = "BufReadPost",
      main = "ibl",
      opts = {},
    },
    { "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true
    },
    {
      "nvim-telescope/telescope.nvim", tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
      "saghen/blink.cmp",
      dependencies = { 'rafamadriz/friendly-snippets' },
      version = '1.*',
      opts = {
        keymap = { preset = 'enter' },
        fuzzy = { implementation = 'lua' },
        completion = { documentation = { auto_show = true } },
      },
    },
    {
      "rmagatti/auto-session",
      keys = { { '<space>o', ':SessionSearch<cr>', mode = { 'n', 'x' } } },
      opts = {
        auto_create = false,
        root_dir = "~/vimfiles/sessions/",
      }
    }
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

vim.cmd('au BufNewFile,BufReadPost *.fs,*.vs set filetype=glsl')
vim.cmd('au BufNewFile,BufReadPost *.json set filetype=jsonc')

-- default settings
local keyset = vim.keymap.set
local silent = { silent = true }


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space>c', builtin.commands, { desc = '' })
vim.keymap.set('n', '<space>b', builtin.buffers, { desc = '' })
vim.keymap.set('n', '<space>r', builtin.oldfiles, { desc = '' })
vim.keymap.set('n', '<space>?', builtin.search_history, { desc = '' })

vim.keymap.set('n', '<space>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<space>g', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<space>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<space>h', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = '' })
vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = '' })
vim.keymap.set('n', '<space>ls', builtin.lsp_document_symbols, { desc = '' })
vim.keymap.set('n', '<space>lS', builtin.lsp_workspace_symbols, { desc = '' })
vim.keymap.set('n', '<space>li', builtin.lsp_incoming_calls, { desc = '' })
vim.keymap.set('n', '<space>lo', builtin.lsp_outgoing_calls, { desc = '' })
vim.keymap.set('n', '<space>ld', builtin.diagnostics, { desc = '' })

local opts = { silent = true, nowait = true, expr = false }
-- g keyshot
keyset("n", "gn", ":bn<cr>", opts)
keyset("n", "gp", ":bp<cr>", opts)
keyset("n", "gq", ":bd%<cr>", opts)
keyset("n", "gQ", ":%bd!|e#|bd#<cr>", opts)
keyset("n", "ga", ":e#<cr>", opts)
keyset({ "n", "x" }, "gh", "0", opts)
keyset({ "n", "x" }, "gs", "^", opts)
keyset({ "n", "x" }, "gl", "$", opts)
keyset("n", "gc", "M", opts)
keyset("n", "ge", "G", opts)
-- misc keyshot
keyset("n", "t", ":BufferLinePick<cr>", opts)
keyset("n", "<S-A-c>", ":e $MYVIMRC<cr>", opts)
keyset("n", "<S-A-r>", ":luafile %<cr>", opts)
keyset({ "n", "x", "i" }, "<C-s>", "<Esc>:w<cr>", silent)
-- moving cursor
keyset({ "n", "i", "t" }, "<C-S-h>", "<C-\\><C-n><C-w>h", opts)
keyset({ "n", "i", "t" }, "<C-S-l>", "<C-\\><C-n><C-w>l", opts)
keyset({ "n", "i", "t" }, "<C-S-j>", "<C-\\><C-n><C-w>j", opts)
keyset({ "n", "i", "t" }, "<C-S-k>", "<C-\\><C-n><C-w>k", opts)
keyset({ "i", "t" }, "<C-v>", '<C-\\><C-n>"0pa', opts)
keyset({ "i", "t" }, "<C-q>", "<C-\\><C-n>", opts)
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
keyset({ "n", "i", "t" }, "<S-M-h>", "<C-\\><C-n>:vertical resize -2<cr>a", opts)
keyset({ "n", "i", "t" }, "<S-M-l>", "<C-\\><C-n>:vertical resize +2<cr>a", opts)
keyset({ "n", "i", "t" }, "<S-M-j>", "<C-\\><C-n>:resize -2<cr>a", opts)
keyset({ "n", "i", "t" }, "<S-M-k>", "<C-\\><C-n>:resize +2<cr>a", opts)

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

keyset({ "n", "i", "t" }, "<M-+>", function() terminal_create('vsplit | wincmd l') end, opts)
keyset({ "n", "i", "t" }, "<M-_>", function() terminal_create('split | wincmd j') end, opts)

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

keyset({ 'n', 'v' }, "gd", vim.lsp.buf.definition, opts)
keyset({ 'n', 'v' }, "gD", vim.lsp.buf.declaration, opts)
keyset({ 'n', 'v' }, "gr", builtin.lsp_references, opts)
keyset({ 'n', 'v' }, "gt", vim.lsp.buf.type_definition, opts)
keyset({ 'n', 'v' }, "gi", builtin.lsp_implementations, opts)
keyset({ 'n', 'v' }, "<A-h>", vim.lsp.buf.document_highlight, opts)
keyset({ 'n', 'v' }, "<S-A-h>", vim.lsp.buf.clear_references, opts)
keyset({ 'n', 'v' }, "<S-A-f>", vim.lsp.buf.format, opts)
keyset({ 'n', 'v' }, "<leader>rn", vim.lsp.buf.rename, opts)
keyset({ 'n', 'v' }, "<leader>ac", vim.lsp.buf.code_action, opts)

vim.lsp.config = {
  lua = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc' },
    settings = {
      Lua = { diagnostics = { globals = { "vim" } } }
    },
  },
  nu = {
    cmd = { 'nu', '--lsp' },
    filetypes = { 'nu', 'nuon' },
  },
  rust = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { ' Cargo.toml', 'cargo.lock' },
    settings = {
      ['rust-analyzer'] = {
        server = { extraEnv = { CARGO_TARGET_DIR = "target/analyzer" } },
        check = { extraArgs = { '--target-dir=target/analzyer' } },
        diagnostics = { disabled = { 'inactive-code' } }
      }
    }
  },
  python = {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'poetry.lock', 'pyrightconfig.json' },
    settings = {
      pylsp = { plugins = { ruff = { lineLength = 120, ignore = { 'E401' } } },
      }
    }
  },
  clangd = {
    cmd = { "clangd" },
    filetypes = { "c", "cc", "cpp", "c++", "objc", "objcpp" },
    root_markers = { "compile_flags.txt", "compile_commands.json" },
  },
  vue = {
    cmd = { "vue-language-server", "--stdio" },
    filetypes = { "vue" },
    root_markers = { "package.json" },
    init_options = { typescript = { tsdk = "node_modules/typescript/lib" } }
  },
  typescript = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "typescript", "vue" },
    init_options = {
      plugins = { {
        name = "@vue/typescript-plugin",
        location = "U:/scoop/.npm-global/node_modules/@vue/typescript-plugin",
        languages = { "javascript", "typescript", "vue" },
      } },
    }
  },
  astro = {
    cmd = { "astro-ls", "--stdio" },
    filetypes = { "astro" },
    init_options = { typescript = { tsdk = "node_modules/typescript/lib" } }
  },
  toml = {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
  },
  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
  },
  css = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css" },
    init_options = {
      provideFormatter = true,
      vue = { hybirdMode = false },
      css = { validate = { enable = true } }
    }
  },
  json = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json" }
  },
  cmake = {
    cmd = { "cmake-language-server" },
    filetypes = { "cmake" },
    root_markers = { "build/" },
    init_options = { buildDirectory = "build" }
  },
  glsl = {
    cmd = { "glsl_analyzer", "--stdio" },
    filetypes = { "glsl", "vert", "tesc", "tese", "geom", "frag", "comp" }
  }
}

for key, _ in pairs(vim.lsp.config) do
  vim.lsp.enable(key)
end


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(ev)
    -- local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    -- if client:supports_method('textDocument/completion') then
    --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    -- end
    -- if not client:supports_method('textDocument/willSaveWaitUntil')
    --     and client:supports_method('textDocument/formatting') then
    --   vim.api.nvim_create_autocmd('BufWritePre', {
    --     group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
    --     buffer = ev.buf,
    --     callback = function()
    --       vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
    --     end,
    --   })
    -- end
  end,
})

vim.diagnostic.config({
  virtual_text = { current_lines = true },
  underline = true,
  update_in_insert = false,
  serverity_sort = true,
  float = { source = "always", border = "rounded" }
})
local signs = { Error = " ", Warn = " ", Hint = "", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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
