-- tmux session picker. Run via `nvim --clean -c 'luafile <this>'`.
-- Reads $TMUX_PICKER_OUT and writes one of:
--   attach:<name>   attach to existing live session
--   resume:<name>   restore from the latest tmux-resurrect snapshot, then attach
--   new:<name>      create new
--   (empty file)    user quit; .zshrc drops to a plain shell

local out_file = vim.env.TMUX_PICKER_OUT
if not out_file or out_file == "" then
  vim.notify("TMUX_PICKER_OUT not set", vim.log.levels.ERROR)
  vim.cmd("qa!")
  return
end

-- Strip "nvim chrome" so the backdrop reads as a blank canvas
vim.opt.cmdheight = 0       -- no empty `:` line at the bottom
vim.opt.laststatus = 0      -- no statusline
vim.opt.showmode = false    -- no -- INSERT -- / -- NORMAL --
vim.opt.ruler = false       -- no cursor-position indicator
vim.opt.showtabline = 0     -- no tabline
vim.opt.fillchars:append("eob: ") -- hide ~ end-of-buffer markers

-- Transparent backdrop (lets Ghostty's bg / desktop show through)
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })

-- Popup colors (Catppuccin Macchiato to match Ghostty theme)
local float_bg = "#24273a"  -- base
vim.api.nvim_set_hl(0, "NormalFloat", { bg = float_bg, fg = "#cad3f5" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_bg, fg = "#8aadf4" })
vim.api.nvim_set_hl(0, "FloatTitle",  { bg = float_bg, fg = "#8aadf4", bold = true })
vim.api.nvim_set_hl(0, "FloatFooter", { bg = float_bg, fg = "#8aadf4" })
vim.api.nvim_set_hl(0, "CursorLine",  { bg = "#363a4f" })  -- surface0

-- Status indicators
vim.api.nvim_set_hl(0, "TmuxPickerAttached", { fg = "#a6da95" })  -- green:  live, attached
vim.api.nvim_set_hl(0, "TmuxPickerDetached", { fg = "#6e738d" })  -- overlay: live, detached
vim.api.nvim_set_hl(0, "TmuxPickerResumable",{ fg = "#f5a97f" })  -- peach:  paused / resumable

-- Hide the cursor block in normal mode; cursorline already marks the selection.
-- Insert mode keeps the default cursor so the new-session prompt remains usable.
vim.opt.guicursor = "n-v-c-sm:block-HiddenCursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-HiddenCursor"
vim.api.nvim_set_hl(0, "HiddenCursor", { bg = "#363a4f", fg = "#cad3f5" })

local picker_ns = vim.api.nvim_create_namespace("tmux_picker")

local function list_sessions()
  local names = vim.fn.systemlist("tmux list-sessions -F '#S' 2>/dev/null")
  if vim.v.shell_error ~= 0 then names = {} end
  local counts = {}
  local clients = vim.fn.systemlist("tmux list-clients -F '#S' 2>/dev/null")
  if vim.v.shell_error == 0 then
    for _, name in ipairs(clients) do counts[name] = (counts[name] or 0) + 1 end
  end
  local result = {}
  for _, name in ipairs(names) do
    local n = counts[name] or 0
    table.insert(result, { kind = "live", name = name, attached = n > 0, count = n })
  end
  return result
end

-- Resurrect writes snapshots to ~/.tmux/resurrect if that dir exists, otherwise
-- to ${XDG_DATA_HOME:-~/.local/share}/tmux/resurrect. `last` is a symlink to
-- the most recent snapshot. Each pane line is tab-separated and starts with
-- `pane<TAB><session_name><TAB>...`.
local function resurrect_last_path()
  local home = vim.env.HOME or ""
  local legacy = home .. "/.tmux/resurrect"
  if vim.fn.isdirectory(legacy) == 1 then return legacy .. "/last" end
  local xdg = vim.env.XDG_DATA_HOME
  if not xdg or xdg == "" then xdg = home .. "/.local/share" end
  return xdg .. "/tmux/resurrect/last"
end

local function list_resumable(live_set)
  local path = resurrect_last_path()
  if vim.fn.filereadable(path) == 0 then return {} end
  local seen, ordered = {}, {}
  for _, line in ipairs(vim.fn.readfile(path)) do
    local kind, sess = line:match("^([^\t]+)\t([^\t]+)")
    if (kind == "pane" or kind == "window") and sess and not live_set[sess] and not seen[sess] then
      seen[sess] = true
      table.insert(ordered, { kind = "resumable", name = sess })
    end
  end
  table.sort(ordered, function(a, b) return a.name < b.name end)
  return ordered
end

local function build_entries()
  local live = list_sessions()
  local live_set = {}
  for _, s in ipairs(live) do live_set[s.name] = true end
  local resumable = list_resumable(live_set)
  local merged = {}
  for _, s in ipairs(live) do table.insert(merged, s) end
  for _, s in ipairs(resumable) do table.insert(merged, s) end
  return merged
end

-- Marker icons: "●" for live sessions, "◌" for resumable (paused/snapshot).
-- Both are 3 bytes in UTF-8, so the extmark end_col is identical.
local MARKER_LIVE     = "●"
local MARKER_RESUMABLE = "◌"

local function render(buf, sessions)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_clear_namespace(buf, picker_ns, 0, -1)
  if #sessions == 0 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "  (no sessions — press n to create one, q to quit)",
    })
  else
    local lines = {}
    for _, s in ipairs(sessions) do
      if s.kind == "resumable" then
        table.insert(lines, " " .. MARKER_RESUMABLE .. " " .. s.name)
      else
        local suffix = s.count >= 2 and (" (" .. s.count .. ")") or ""
        table.insert(lines, " " .. MARKER_LIVE .. " " .. s.name .. suffix)
      end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    for i, s in ipairs(sessions) do
      local hl
      if s.kind == "resumable" then
        hl = "TmuxPickerResumable"
      else
        hl = s.attached and "TmuxPickerAttached" or "TmuxPickerDetached"
      end
      vim.api.nvim_buf_set_extmark(buf, picker_ns, i - 1, 1, {
        end_col = 4,         -- 3-byte UTF-8 marker
        hl_group = hl,
      })
    end
  end
  vim.bo[buf].modifiable = false
end

local function write_choice(action, name)
  vim.fn.writefile({ action .. ":" .. name }, out_file)
end

-- Keep the first Ghostty tab whose title matches `name` (in window/tab order)
-- and close any duplicates.
local function dedupe_ghostty_tabs_by_name(name)
  local script = [[
on run argv
  set target_name to item 1 of argv
  tell application "Ghostty"
    set keeper to missing value
    set doomed to {}
    repeat with w in windows
      repeat with t in tabs of w
        if name of t is target_name then
          if keeper is missing value then
            set keeper to t
          else
            set end of doomed to t
          end if
        end if
      end repeat
    end repeat
    repeat with t in doomed
      tell t to close tab
    end repeat
  end tell
end run
]]
  vim.fn.system({ "osascript", "-", name }, script)
end

-- Close every Ghostty tab whose title matches `name` (tmux's set-titles makes
-- the tab title equal the session name, so this finds the tabs that were
-- attached to the just-killed session).
local function close_ghostty_tabs_by_name(name)
  local script = [[
on run argv
  set target_name to item 1 of argv
  tell application "Ghostty"
    set doomed to {}
    repeat with w in windows
      repeat with t in tabs of w
        if name of t is target_name then
          set end of doomed to t
        end if
      end repeat
    end repeat
    repeat with t in doomed
      tell t to close tab
    end repeat
  end tell
end run
]]
  vim.fn.system({ "osascript", "-", name }, script)
end

local sessions  -- forward-declared; reassigned after render-on-init and on refresh

local function current_session()
  if not sessions or #sessions == 0 then return nil end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  return sessions[lnum]
end

-- Blank out the main window so the float feels like the whole UI
local bg_buf = vim.api.nvim_create_buf(false, true)
vim.bo[bg_buf].buftype = "nofile"
vim.bo[bg_buf].bufhidden = "wipe"
vim.api.nvim_win_set_buf(0, bg_buf)

-- Picker buffer
local buf = vim.api.nvim_create_buf(false, true)
vim.bo[buf].buftype = "nofile"
vim.bo[buf].bufhidden = "hide"  -- keep alive while we swap to/from the prompt
vim.bo[buf].swapfile = false
vim.api.nvim_buf_set_name(buf, "tmux-sessions")

sessions = build_entries()
render(buf, sessions)

-- Geometry helper: positions the backdrop first (centered on screen) and the
-- popup inside it, so the halo padding stays symmetric regardless of how nvim
-- accounts for borders. Pass the popup's *content* height (number of rows).
local pad_x, pad_y = 5, 3
local win, backdrop_win  -- forward-declared, assigned after compute_geometry

local function compute_geometry(content_h)
  local ui = vim.api.nvim_list_uis()[1]
  local w = math.min(70, ui.width - 4)
  local h = math.min(math.max(content_h, 1), 15)
  local popup_outer_w = w + 2
  local popup_outer_h = h + 2
  local backdrop_w = popup_outer_w + pad_x * 2
  local backdrop_h = popup_outer_h + pad_y * 2
  local backdrop_outer_w = backdrop_w + 2
  local backdrop_outer_h = backdrop_h + 2
  local b_row = math.max(math.floor((ui.height - backdrop_outer_h) / 2), 0)
  local b_col = math.max(math.floor((ui.width - backdrop_outer_w) / 2), 0)
  return {
    popup    = { width = w, height = h, row = b_row + 1 + pad_y, col = b_col + 1 + pad_x },
    backdrop = { width = backdrop_w, height = backdrop_h, row = b_row, col = b_col },
  }
end

local function apply_geometry(g)
  vim.api.nvim_win_set_config(win, {
    relative = "editor",
    width = g.popup.width, height = g.popup.height,
    row = g.popup.row, col = g.popup.col,
  })
  vim.api.nvim_win_set_config(backdrop_win, {
    relative = "editor",
    width = g.backdrop.width, height = g.backdrop.height,
    row = g.backdrop.row, col = g.backdrop.col,
  })
end

local initial_g = compute_geometry(#sessions)

local backdrop_buf = vim.api.nvim_create_buf(false, true)
vim.bo[backdrop_buf].buftype = "nofile"
vim.bo[backdrop_buf].bufhidden = "wipe"
vim.api.nvim_set_hl(0, "TmuxPickerBackdrop", { bg = float_bg })
backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
  relative = "editor",
  width = initial_g.backdrop.width,
  height = initial_g.backdrop.height,
  col = initial_g.backdrop.col,
  row = initial_g.backdrop.row,
  style = "minimal",
  border = "rounded",
  focusable = false,
  zindex = 40,
})
vim.wo[backdrop_win].winhighlight = "Normal:TmuxPickerBackdrop,NormalNC:TmuxPickerBackdrop"

win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = initial_g.popup.width,
  height = initial_g.popup.height,
  col = initial_g.popup.col,
  row = initial_g.popup.row,
  style = "minimal",
  border = "rounded",
  title = " tmux sessions ",
  title_pos = "center",
  footer = " <CR> go · F force · n new · d kill · D dedupe · q close · Q shell ",
  footer_pos = "center",
})

vim.wo[win].cursorline = true
vim.wo[win].number = false
vim.wo[win].relativenumber = false
vim.wo[win].signcolumn = "no"

local function map(key, fn, desc)
  vim.keymap.set("n", key, fn, { buffer = buf, nowait = true, silent = true, desc = desc })
end

map("<CR>", function()
  local s = current_session()
  if not s then return end
  if s.kind == "resumable" then
    write_choice("resume", s.name)
  else
    write_choice(s.attached and "focus" or "attach", s.name)
  end
  vim.cmd("qa!")
end, "Attach, focus, or resume entry under cursor")

map("F", function()
  local s = current_session()
  if not s or s.kind == "resumable" then return end
  write_choice("attach", s.name)
  vim.cmd("qa!")
end, "Force-attach in this tab (duplicate)")

map("n", function()
  local prompt_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[prompt_buf].buftype = "prompt"
  vim.bo[prompt_buf].bufhidden = "wipe"
  vim.fn.prompt_setprompt(prompt_buf, "session name › ")
  vim.fn.prompt_setcallback(prompt_buf, function(text)
    if text and text ~= "" then write_choice("new", text) end
    vim.cmd("qa!")
  end)

  vim.keymap.set({ "i", "n" }, "<Esc>", function()
    vim.cmd("stopinsert")
    vim.api.nvim_win_set_buf(win, buf)
    apply_geometry(compute_geometry(#sessions))
    vim.api.nvim_win_set_config(win, {
      title = " tmux sessions ",
      footer = " <CR> go · F force · n new · d kill · D dedupe · q close · Q shell ",
    })
  end, { buffer = prompt_buf, nowait = true })

  vim.api.nvim_win_set_buf(win, prompt_buf)
  apply_geometry(compute_geometry(1))  -- prompt only needs one row
  vim.api.nvim_win_set_config(win, {
    title = " new session ",
    footer = " <CR> confirm · <Esc> cancel ",
  })
  vim.cmd("startinsert")
end, "Create new session")

map("d", function()
  local s = current_session()
  if not s or s.kind == "resumable" then return end
  local name, was_attached = s.name, s.attached
  vim.fn.system({ "tmux", "kill-session", "-t", name })
  if was_attached then close_ghostty_tabs_by_name(name) end
  sessions = build_entries()
  render(buf, sessions)
  apply_geometry(compute_geometry(#sessions))
end, "Kill session under cursor")

map("D", function()
  local s = current_session()
  if not s or s.kind == "resumable" or s.count < 2 then return end
  dedupe_ghostty_tabs_by_name(s.name)
  write_choice("focus", s.name)
  vim.cmd("qa!")
end, "Close duplicate tabs and jump to the keeper")

map("q", function()
  write_choice("close", "")
  vim.cmd("qa!")
end, "Close Ghostty tab")

map("Q", function()
  vim.cmd("qa!")
end, "Drop to plain shell")
