-- LazyVim already sets number, relativenumber, expandtab, shiftwidth=2
-- and tabstop=2, so only genuine deviations belong here.

-- Never persist registers to the shada file (they can leak secrets to disk)
vim.opt.shada = "'100,<0,s10,h"

-- Make <Tab>/<BS> operate on 2 spaces at a time (Neovim defaults to 0)
vim.opt.softtabstop = 2
