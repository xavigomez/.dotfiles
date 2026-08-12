vim.opt.number = true
vim.opt.relativenumber = true
-- Never persist registers to the shada file (they can leak secrets to disk)
vim.opt.shada = "'100,<0,s10,h"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
