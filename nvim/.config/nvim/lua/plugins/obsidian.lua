return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- Recommended: use latest release
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    workspaces = {
      {
        name = "vault",  -- Generic name for the vault
        path = "~/.obsidian",
      },
      -- You can add additional vaults here if needed
      -- {
      --   name = "work-vault",
      --   path = "~/another/vault/location",
      -- },
    },
    -- Optional: Configure where new notes go
    notes_subdir = "notes",
    new_notes_location = "notes_subdir",
    
    completion = {
      min_chars = 2,
    },
    
    -- Key mappings (Obsidian-specific, buffer-local to markdown files)
    mappings = {
      -- Override gf to work on markdown/wiki links
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle checkboxes
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action (follow link or toggle checkbox)
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    
    -- UI enhancements (concealing, etc.)
    ui = {
      enable = true,
      update_debounce = 200,
      max_file_length = 5000,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
      },
      bullets = { char = "•", hl_group = "ObsidianBullet" },
      external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      reference_text = { hl_group = "ObsidianRefText" },
      tags = { hl_group = "ObsidianTag" },
      block_ids = { hl_group = "ObsidianBlockID" },
      hl_groups = {
        ObsidianTodo = { bold = true, fg = "#f78c6c" },
        ObsidianDone = { bold = true, fg = "#89ddff" },
        ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
        ObsidianTilde = { bold = true, fg = "#ff5370" },
        ObsidianImportant = { bold = true, fg = "#d73128" },
        ObsidianBullet = { bold = true, fg = "#89ddff" },
        ObsidianRefText = { underline = true, fg = "#c792ea" },
        ObsidianExtLinkIcon = { fg = "#c792ea" },
        ObsidianTag = { italic = true, fg = "#89ddff" },
        ObsidianBlockID = { italic = true, fg = "#89ddff" },
        ObsidianHighlightText = { bg = "#75662e" },
      },
    },
    
    -- Attachments configuration
    attachments = {
      img_folder = "assets/imgs",  -- Adjust as needed
      img_name_func = function()
        return string.format("%s-", os.time())
      end,
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },
  },
  -- Optional: Add commands to manually enable/disable obsidian functionality
  config = function(_, opts)
    require("obsidian").setup(opts)
    
    -- Create user commands to toggle obsidian features on demand
    vim.api.nvim_create_user_command("ObsidianEnable", function()
      require("obsidian").setup(opts)
      vim.notify("Obsidian.nvim enabled", vim.log.levels.INFO)
    end, { desc = "Enable Obsidian.nvim features in current buffer" })
    
    vim.api.nvim_create_user_command("ObsidianDisable", function()
      pcall(vim.api.nvim_buf_del_keymap, 0, "n", "gf")
      pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>ch")
      pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<cr>")
      vim.notify("Obsidian.nvim disabled", vim.log.levels.INFO)
    end, { desc = "Disable Obsidian.nvim features in current buffer" })
  end,
}