-- Seamless ctrl+hjkl navigation across nvim splits and herdr panes
-- (vim-tmux-navigator style: at nvim's edge the key is forwarded to herdr).
local M = {}

local HERDR_DIRECTIONS = { h = "left", j = "down", k = "up", l = "right" }

local function herdr_bin()
  local path = vim.env.HERDR_BIN_PATH
  if path and path ~= "" then
    return path
  end
  return "herdr"
end

local function in_herdr()
  return (vim.env.HERDR_PANE_ID or "") ~= ""
end

local function is_float(win)
  return vim.api.nvim_win_get_config(win or 0).relative ~= ""
end

-- Nearest floating window parked in direction `dir` relative to the current
-- window (explorer sidebars, pickers…), or nil. Floats don't participate in
-- winnr()/wincmd navigation, so they need explicit handling.
local function float_towards(dir)
  local pos = vim.fn.win_screenpos(vim.fn.winnr())
  local cur = { row = pos[1], col = pos[2] }
  local best
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= vim.api.nvim_get_current_win() and is_float(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      local row, col = tonumber(cfg.row) or 0, tonumber(cfg.col) or 0
      local towards = (dir == "h" and col < cur.col)
        or (dir == "l" and col > cur.col)
        or (dir == "j" and row > cur.row)
        or (dir == "k" and row < cur.row)
      if towards then
        local dist = (dir == "h" and (cur.col - col))
          or (dir == "l" and (col - cur.col))
          or (dir == "j" and (row - cur.row))
          or (cur.row - row)
        if not best or dist < best.dist then
          best = { win = win, dist = dist }
        end
      end
    end
  end
  return best and best.win or nil
end

local function focus_herdr(dir)
  vim.system({ herdr_bin(), "pane", "focus", "--direction", dir, "--current" }, { detach = true })
end

function M.move(dir)
  if vim.api.nvim_get_mode().mode == "t" then
    vim.cmd.stopinsert()
  end

  if not is_float() then
    if vim.fn.winnr(dir) ~= vim.fn.winnr() then
      vim.cmd.wincmd(dir)
      return
    end
    -- At nvim's edge: step into a float parked on that side (explorer sidebar)
    -- before handing off to herdr.
    local float = float_towards(dir)
    if float then
      vim.api.nvim_set_current_win(float)
      return
    end
    if in_herdr() then
      focus_herdr(HERDR_DIRECTIONS[dir])
      return
    end
  end

  vim.cmd.wincmd(dir)
end

M.is_float = is_float

return M
