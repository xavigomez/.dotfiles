-- tmux session picker. Run via `nvim --clean -c 'luafile <this>'`.
-- Reads $TMUX_PICKER_OUT and writes one of:
--   attach:<name>   attach to existing
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

local function list_sessions()
  local names = vim.fn.systemlist("tmux list-sessions -F '#S' 2>/dev/null")
  if vim.v.shell_error ~= 0 then names = {} end
  local attached = {}
  local clients = vim.fn.systemlist("tmux list-clients -F '#S' 2>/dev/null")
  if vim.v.shell_error == 0 then
    for _, name in ipairs(clients) do attached[name] = true end
  end
  local result = {}
  for _, name in ipairs(names) do
    table.insert(result, { name = name, attached = attached[name] == true })
  end
  return result
end

local function render(buf, sessions)
  vim.bo[buf].modifiable = true
  if #sessions == 0 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "  (no sessions — press n to create one, q to quit)",
    })
  else
    local lines = {}
    for _, s in ipairs(sessions) do
      local prefix = s.attached and "● " or "  "
      table.insert(lines, prefix .. s.name)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
  vim.bo[buf].modifiable = false
end

local function write_choice(action, name)
  vim.fn.writefile({ action .. ":" .. name }, out_file)
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

sessions = list_sessions()
render(buf, sessions)

local ui = vim.api.nvim_list_uis()[1]
local width = math.min(60, ui.width - 4)
local height = math.min(math.max(#sessions, 1), 15)

-- Position by sizing the backdrop first, then placing the popup inside it.
-- This makes the popup's centering within the backdrop independent of how
-- nvim accounts for borders when interpreting `row`/`col`.
local pad_x, pad_y = 5, 3                        -- halo around the popup, in cells
local popup_outer_w = width + 2                  -- popup + its border
local popup_outer_h = height + 2
local backdrop_content_w = popup_outer_w + pad_x * 2
local backdrop_content_h = popup_outer_h + pad_y * 2
local backdrop_outer_w = backdrop_content_w + 2  -- + backdrop's own border
local backdrop_outer_h = backdrop_content_h + 2

local backdrop_row = math.max(math.floor((ui.height - backdrop_outer_h) / 2), 0)
local backdrop_col = math.max(math.floor((ui.width - backdrop_outer_w) / 2), 0)
local row = backdrop_row + 1 + pad_y             -- skip backdrop's top border + halo
local col = backdrop_col + 1 + pad_x

local backdrop_buf = vim.api.nvim_create_buf(false, true)
vim.bo[backdrop_buf].buftype = "nofile"
vim.bo[backdrop_buf].bufhidden = "wipe"
vim.api.nvim_set_hl(0, "TmuxPickerBackdrop", { bg = float_bg })
local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
  relative = "editor",
  width = backdrop_content_w,
  height = backdrop_content_h,
  col = backdrop_col,
  row = backdrop_row,
  style = "minimal",
  border = "rounded",
  focusable = false,
  zindex = 40,
})
vim.wo[backdrop_win].winhighlight = "Normal:TmuxPickerBackdrop,NormalNC:TmuxPickerBackdrop"

local win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = width,
  height = height,
  col = col,
  row = row,
  style = "minimal",
  border = "rounded",
  title = " tmux sessions ",
  title_pos = "center",
  footer = " <CR> go · F force · n new · d kill · q close · Q shell ",
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
  write_choice(s.attached and "focus" or "attach", s.name)
  vim.cmd("qa!")
end, "Attach or focus existing tab")

map("F", function()
  local s = current_session()
  if not s then return end
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
    vim.api.nvim_win_set_config(win, {
      title = " tmux sessions ",
      footer = " <CR> go · F force · n new · d kill · q close · Q shell ",
    })
  end, { buffer = prompt_buf, nowait = true })

  vim.api.nvim_win_set_buf(win, prompt_buf)
  vim.api.nvim_win_set_config(win, {
    title = " new session ",
    footer = " <CR> confirm · <Esc> cancel ",
  })
  vim.cmd("startinsert")
end, "Create new session")

map("d", function()
  local s = current_session()
  if not s then return end
  vim.fn.system({ "tmux", "kill-session", "-t", s.name })
  sessions = list_sessions()
  render(buf, sessions)
end, "Kill session under cursor")

map("q", function()
  write_choice("close", "")
  vim.cmd("qa!")
end, "Close Ghostty tab")

map("Q", function()
  vim.cmd("qa!")
end, "Drop to plain shell")
