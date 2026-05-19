return {
  "mrcjkb/rustaceanvim",
  opts = function(_, opts)
    opts.server = opts.server or {}
    local prev_on_attach = opts.server.on_attach
    opts.server.on_attach = function(client, bufnr)
      if prev_on_attach then
        prev_on_attach(client, bufnr)
      end
      vim.keymap.set("n", "<leader>cu", function()
        vim.cmd.RustLsp("runnables")
      end, { desc = "Rust Runnables", buffer = bufnr })
    end
  end,
}
