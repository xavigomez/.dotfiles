-- Language support lives in lazyvim.json extras (:LazyExtras).
-- Only put things here that no extra covers.
return {
  {
    "neovim/nvim-lspconfig",
      opts = {
        servers = {
          -- LazyVim has no CSS extra, so cssls is configured by hand.
          cssls = {},
          -- Emmet abbreviations. Ships with astro/typescriptreact/svelte/vue
          -- in its default filetypes, so no includeLanguages needed.
          emmet_language_server = {},
          -- Eslint and vtsls both report unused TS variables. When eslint is
          -- attached to the buffer, drop vtsls's hint codes (6133 et al.) and
          -- keep eslint's more configurable report; without eslint, the hint
          -- still shows. Rationale + verification: docs/nvim-vtsls-eslint-dedupe.md
          vtsls = {
            handlers = {
              ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                local drop = { [6133] = true, [6192] = true, [6196] = true, [6198] = true }
                if result and result.diagnostics and #vim.lsp.get_clients({ bufnr = ctx.bufnr, name = "eslint" }) > 0 then
                  result.diagnostics = vim
                    .iter(result.diagnostics)
                    :filter(function(d)
                      return not drop[d.code]
                    end)
                    :totable()
                end
                vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
              end,
            },
          },
        },
      },
  },

  -- Parsers not in LazyVim's defaults or in any enabled extra.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "scss", "jsonc" } },
  },
}
