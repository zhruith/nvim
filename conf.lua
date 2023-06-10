local icons = require('icons')
local use_icons = true
---------------- ayutheme config ----------------

-- :lua print(vim.inspect(require('ayu.colors')))
local ayu = require 'ayu.colors'
local line = "#273747"
local gray = { fg = 'gray' }

require('ayu').setup {
  overrides = function()
    return {
      Normal = { bg = nil },
      --TabLineFill = { bg = nil },
      --FloatBorder = {bg='#ff00ff',fg='white'},
      NormalFloat = { bg = line },
      SignColumn = { bg = nil },
      VertSplit = { fg = ayu.ui },
      Visual = { bg = ayu.selection_border },
      CursorLine = { bg = line },
      CursorLineNr = { bg = line },
      Search = { bg = ayu.ui },
      Comment = gray,
      LineNr = { fg = ayu.comment },
      CocHighlightText = { bg = '#505050' },
      NonText = gray,
      DiagnosticHint = gray,
      SpecialKey = gray,
      NvimTreeIndentMarker = gray,
    }
  end,
}

require 'ayu'.colorscheme()

---------------- gitsigns config ------------------

require('gitsigns').setup {
  signs = {
    add = {
      text = icons.ui.LineMiddle,
      hl = "GitSignsAdd",
      numhl = "GitSignsAddNr",
      linehl = "GitSignsAddLn",
    },
    change = {
      text = icons.ui.LineMiddle,
      hl = "GitSignsChange",
      numhl = "GitSignsChangeNr",
      linehl = "GitSignsChangeLn",
    },
    delete = {
      text = icons.ui.Triangle,
      hl = "GitSignsDelete",
      numhl = "GitSignsDeleteNr",
      linehl = "GitSignsDeleteLn",
    },
    topdelete = {
      text = icons.ui.Triangle,
      hl = "GitSignsDelete",
      numhl = "GitSignsDeleteNr",
      linehl = "GitSignsDeleteLn",
    },
    changedelete = {
      text = icons.ui.LineMiddle,
      hl = "GitSignsChange",
      numhl = "GitSignsChangeNr",
      linehl = "GitSignsChangeLn",
    },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 100,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 6,
  status_formatter = nil, -- Use default
  update_debounce = 200,
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "rounded",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  yadm = { enable = false },

}

-------------- lualine config ----------------

local llayu = require 'lualine.themes.ayu'
llayu.normal.c = { fg = 'darkgray', bg = nil }

require('lualine').setup {
  options = {
    theme = llayu,
    globalstatus = true,
    component_separators = '·',
    --component_separators = { right = icons.ui.TriangleShortArrowLeft, left = icons.ui.TriangleShortArrowRight },
    section_separators = {
      left = icons.ui.SemicircleRight,
      right = icons.ui.SemicircleLeft
    },
    disabled_filetypes = {
      statusline = { '', 'list' },
      winbar = {}
    },
  },
  sections = {
    lualine_a = {
      {
        function() return ' ' .. icons.misc.Vimlogo2 end,
        padding = 0,
      },
    },
    lualine_b = {
      'branch',
    },
    lualine_c = {
      'filename',
      {
        'diff',
        colored = true,
        diff_color = {
          added = { fg = ayu.vcs_added },
          modified = { fg = ayu.vcs_modified },
          removed = { fg = ayu.vcs_removed },
        },
        symbols = {
          added = icons.git.LineAdded .. ' ',
          modified = icons.git.LineRemoved .. ' ',
          removed = icons.git.LineRemoved .. ' ',
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
      'g:coc_status',
    },
    lualine_x = {
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.BoldError .. ' ',
          warn = icons.diagnostics.BoldWarning .. ' ',
          info = icons.diagnostics.BoldInformation .. ' ',
          hint = icons.diagnostics.BoldHint .. ' ',
        },
      },
      'fileformat',
      'filetype',
      { 'datetime', style = '%H:%M' } },
    lualine_y = {
      'progress',
      {
        'progress',
        fmt = function() return "%L" end,
      },
    },
    lualine_z = { 'location' },
  },
}
---------------- toggleterm config ------------------

require('toggleterm').setup {
  persist_mode = false,
  persist_size = true,
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

-------------- bufferline config --------------------

local function is_ft(b, ft)
  return vim.bo[b].filetype == ft
end

local function diagnostics_indicator(num, _, diagnostics, _)
  local result = {}
  local symbols = {
    error = icons.diagnostics.BoldError,
    warning = icons.diagnostics.BoldWarning,
    info = icons.diagnostics.BoldInformation,
  }
  if not use_icons then
    return "(" .. num .. ")"
  end
  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. "" .. count)
    end
  end
  --result = table.concat(result, " ")
  return #result > 0 and result or ""
end

local function custom_filter(buf, buf_nums)
  local logs = vim.tbl_filter(function(b)
    return is_ft(b, "log")
  end, buf_nums or {})
  if vim.tbl_isempty(logs) then
    return true
  end
  local tab_num = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr "$"
  local is_log = is_ft(buf, "log")
  if last_tab == 1 then
    return true
  end
  -- only show log buffers in secondary tabs
  return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
end

local bufferline = require('bufferline')
bufferline.setup {
  options = {
    style_preset = {
      bufferline.style_preset.no_italic,
      bufferline.style_preset.nobold,
    },
    always_show_bufferline = false,
    offsets = { { filetype = 'NvimTree' } },
    diagnostics = 'coc',
    diagnostics_update_in_insert = false,
    diagnostics_indicator = diagnostics_indicator,
    custom_filter = custom_filter,
  },
}

---------------- nvim-tree config ----------------


local function on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return {
      desc = "nvim-tree: " .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true
    }
  end

  api.config.mappings.default_on_attach(bufnr)

  local useful_keys = {
    ["l"] = { api.node.open.edit, opts "Open" },
    ["o"] = { api.node.open.edit, opts "Open" },
    ["h"] = { api.node.navigate.parent_close, opts "Close Directory" },
    ["C"] = { api.tree.change_root_to_node, opts "CD" },
  }

  for k, v in pairs(useful_keys) do
    vim.keymap.set('n', k, v[1], v[2])
  end
end


require('nvim-tree').setup {
  auto_reload_on_write = false,
  disable_netrw = false,
  hijack_cursor = false,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  sort_by = "name",
  root_dirs = {},
  prefer_startup_root = false,
  sync_root_with_cwd = true,
  reload_on_bufenter = false,
  respect_buf_cwd = true,
  on_attach = on_attach,
  remove_keymaps = false,
  select_prompts = false,
  view = {
    adaptive_size = false,
    centralize_selection = true,
    width = 30,
    hide_root_folder = false,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    float = {
      enable = false,
      quit_on_focus_loss = true,
      open_win_config = {
        relative = "editor",
        border = "rounded",
        width = 30,
        height = 30,
        row = 1,
        col = 1,
      },
    },
  },
  renderer = {
    add_trailing = false,
    group_empty = false,
    highlight_git = true,
    full_name = false,
    highlight_opened_files = "none",
    root_folder_label = ":t",
    indent_width = 2,
    indent_markers = {
      enable = false,
      inline_arrows = true,
      icons = {
        corner = "└",
        edge = "│",
        item = "│",
        none = " ",
      },
    },
    icons = {
      webdev_colors = use_icons,
      git_placement = "before",
      padding = " ",
      symlink_arrow = " ➛ ",
      show = {
        file = use_icons,
        folder = use_icons,
        folder_arrow = use_icons,
        git = use_icons,
      },
      glyphs = {
        default = icons.ui.Text,
        symlink = icons.ui.FileSymlink,
        bookmark = icons.ui.BookMark,
        folder = {
          arrow_closed = icons.ui.TriangleShortArrowRight,
          arrow_open = icons.ui.TriangleShortArrowDown,
          default = icons.ui.Folder,
          open = icons.ui.FolderOpen,
          empty = icons.ui.EmptyFolder,
          empty_open = icons.ui.EmptyFolderOpen,
          symlink = icons.ui.FolderSymlink,
          symlink_open = icons.ui.FolderOpen,
        },
        git = {
          unstaged = icons.git.FileUnstaged,
          staged = icons.git.FileStaged,
          unmerged = icons.git.FileUnmerged,
          renamed = icons.git.FileRenamed,
          untracked = icons.git.FileUntracked,
          deleted = icons.git.FileDeleted,
          ignored = icons.git.FileIgnored,
        },
      },
    },
    special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
    symlink_destination = true,
  },
  hijack_directories = {
    enable = false,
    auto_open = true,
  },
  update_focused_file = {
    enable = true,
    debounce_delay = 15,
    update_root = true,
    ignore_list = {},
  },
  diagnostics = {
    enable = use_icons,
    show_on_dirs = false,
    show_on_open_dirs = true,
    debounce_delay = 50,
    severity = {
      min = vim.diagnostic.severity.HINT,
      max = vim.diagnostic.severity.ERROR,
    },
    icons = {
      hint = icons.diagnostics.BoldHint,
      info = icons.diagnostics.BoldInformation,
      warning = icons.diagnostics.BoldWarning,
      error = icons.diagnostics.BoldError,
    },
  },
  filters = {
    dotfiles = false,
    git_clean = false,
    no_buffer = false,
    custom = { "node_modules", "\\.cache" },
    exclude = {},
  },
  filesystem_watchers = {
    enable = true,
    debounce_delay = 50,
    ignore_dirs = {},
  },
  git = {
    enable = true,
    ignore = false,
    show_on_dirs = true,
    show_on_open_dirs = true,
    timeout = 200,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = false,
      global = true,
      restrict_above_cwd = true,
    },
    expand_all = {
      max_folder_discovery = 300,
      exclude = {},
    },
    file_popup = {
      open_win_config = {
        col = 1,
        row = 1,
        relative = "cursor",
        border = "shadow",
        style = "minimal",
      },
    },
    open_file = {
      quit_on_open = false,
      resize_window = false,
      window_picker = {
        enable = true,
        picker = "default",
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
    remove_file = {
      close_window = true,
    },
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
  live_filter = {
    prefix = "[FILTER]: ",
    always_show_folders = true,
  },
  tab = {
    sync = {
      open = false,
      close = false,
      ignore = {},
    },
  },
  notify = {
    threshold = vim.log.levels.INFO,
  },
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      dev = false,
      diagnostics = false,
      git = false,
      profile = false,
      watcher = false,
    },
  },
  system_open = {
    cmd = nil,
    args = {},
  },
}


---------------- treesitter config ----------------

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'rust', 'python', 'c', 'cpp', 'toml', 'vim', 'vimdoc', 'vue' },
  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require('nvim-web-devicons').setup {
  color_icons = true,
  default = true,
  strict = true,
}




local function buf_kill(kill_command, bufnr, force)
  kill_command = 'bd'

  local bo = vim.bo
  local api = vim.api
  local fmt = string.format
  local fnamemodify = vim.fn.fnamemodify

  if bufnr == 0 or bufnr == nil then
    bufnr = api.nvim_get_current_buf()
  end

  local bufname = api.nvim_buf_get_name(bufnr)

  if not force then
    local warning
    if bo[bufnr].modified then
      warning = fmt([[No write since last change for (%s)]], fnamemodify(bufname, ":t"))
    elseif api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
      warning = fmt([[Terminal %s will be killed]], bufname)
    end
    if warning then
      vim.ui.input({
        prompt = string.format([[%s. Close it anyway? [y]es or [n]o (default: no): ]], warning),
      }, function(choice)
        if choice ~= nil and choice:match "ye?s?" then buf_kill(kill_command, bufnr, true) end
      end)
      return
    end
  end

  -- Get list of windows IDs with the buffer to close
  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, api.nvim_list_wins())

  if force then
    kill_command = kill_command .. "!"
  end

  -- Get list of active buffers
  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
  end, api.nvim_list_bufs())

  -- If there is only one buffer (which has to be the current one), vim will
  -- create a new buffer on :bd.
  -- For more than one buffer, pick the previous buffer (wrapping around if necessary)
  if #buffers > 1 and #windows > 0 then
    for i, v in ipairs(buffers) do
      if v == bufnr then
        local prev_buf_idx = i == 1 and #buffers or (i - 1)
        local prev_buffer = buffers[prev_buf_idx]
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, prev_buffer)
        end
      end
    end
  end

  -- Check if buffer still exists, to ensure the target buffer wasn't killed
  -- due to options like bufhidden=wipe.
  if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
    vim.cmd(string.format("%s %d", kill_command, bufnr))
  end
end

local opts = vim.tbl_deep_extend("force", { force = true }, {})
vim.api.nvim_create_user_command('BufferKill', buf_kill, opts)
