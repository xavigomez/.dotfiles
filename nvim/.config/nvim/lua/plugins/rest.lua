-- HTTP client for .http files. Replaces LazyVim's util.rest extra, whose
-- kulala.nvim now needs a license token for its closed-source core.
return {
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    -- The rockspec's tree-sitter-http rock fails to build under lazy's
    -- hererocks (missing treesitter-parser build backend). nvim-treesitter
    -- already provides the parser, so install only the pure-Lua deps into the
    -- tree lazy puts on package.path for this plugin.
    build = function(plugin)
      local rocks = require("lazy.core.config").options.rocks.root
      for _, rock in ipairs({ "nvim-nio", "fidget.nvim", "mimetypes", "xml2lua" }) do
        local res = vim.system({
          rocks .. "/hererocks/bin/luarocks",
          "--tree", rocks .. "/" .. plugin.name,
          "--lua-version", "5.1",
          "install", rock,
        }):wait()
        assert(res.code == 0, "luarocks install " .. rock .. " failed:\n" .. (res.stderr or ""))
      end
    end,
    -- rest.nvim's .env auto-detect stops before searching cwd, so a .http
    -- file in a subfolder never finds the root .env. Search all the way up.
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "http",
        callback = function(ev)
          vim.schedule(function()
            if vim.b[ev.buf]._rest_nvim_env_file then return end
            vim.b[ev.buf]._rest_nvim_env_file = vim.fs.find(".env", {
              upward = true,
              path = vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf)),
            })[1]
          end)
        end,
      })
    end,
    keys = {
      { "<leader>R", "", desc = "+Rest", ft = "http" },
      { "<leader>Rs", "<cmd>Rest run<cr>", desc = "Send request", ft = "http" },
      { "<leader>Rr", "<cmd>Rest last<cr>", desc = "Replay last request", ft = "http" },
      { "<leader>Ro", "<cmd>Rest open<cr>", desc = "Open result pane", ft = "http" },
      { "<leader>Re", "<cmd>Rest env select<cr>", desc = "Select env file", ft = "http" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "http" } },
  },
}
