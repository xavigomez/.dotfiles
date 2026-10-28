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
      -- Full cargo-style error (arrows, notes, help) instead of the split-up virtual text.
      vim.keymap.set("n", "<leader>cD", function()
        vim.cmd.RustLsp("renderDiagnostic")
      end, { desc = "Rust Render Diagnostic", buffer = bufnr })
      vim.keymap.set("n", "<leader>ce", function()
        vim.cmd.RustLsp("explainError")
      end, { desc = "Rust Explain Error", buffer = bufnr })
    end
  end,
}
