# Neovim + Obsidian Integration

Documentation for configuring Neovim (via LazyVim) to work seamlessly with Obsidian vaults while maintaining a clean development environment.

## Overview & Purpose

This setup integrates the [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) plugin with LazyVim to provide full Obsidian-like functionality (wiki links, tags, daily notes, etc.) when working within your Obsidian vault, while ensuring zero interference with your standard development workflow outside the vault.

**Key Benefits:**
- Full Obsidian features available in Neovim when editing vault markdown files
- Clean development environment - no Obsidian completion or key mappings in code files
- Seamless switching between vault work and regular development
- Git version control compatible with standard workflows

## Installation & Setup

### Plugin Installation
The `obsidian.nvim` plugin is installed via LazyVim in `~/.dotfiles/nvim/lua/plugins/obsidian.lua`:

```lua
return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- Use latest release
  lazy = true,    -- No automatic triggers; loaded only by vault autocmd or ObsidianEnableManual
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  -- Configuration options detailed below
}
```

### Vault Requirements
- Your primary Obsidian vault should be located at `~/.obsidian`
- The plugin loads automatically when Neovim's CWD is inside the vault, or when opening any `.md` file within it
- It can also be loaded on demand with `:ObsidianEnableManual` from any buffer
- Additional vaults can be configured by modifying the `workspaces` array

### Dependencies Note
All dependencies are already included in a standard LazyVim installation:
- ✅ `nvim-lua/plenary.nvim` - Core LazyVim dependency
- ✅ `nvim-telescope/telescope.nvim` - Telescope (LazyVim default)
- ✅ `nvim-treesitter/nvim-treesitter` - Treesitter (LazyVim default)

Only `obsidian.nvim` needs to be added as a new plugin.

## Core Configuration Details

### Plugin Scoping
The plugin has no automatic filetype trigger (`ft`) — it is strictly lazy with three load paths:
1. **CWD-based**: If Neovim is opened with CWD inside `~/.obsidian`, the plugin loads at `VimEnter`
2. **File-based**: `BufEnter` on any `*.md` file checks if it's inside the vault via `in_vault()`
3. **Manual**: `:ObsidianEnableManual` command from any buffer

### Enabled Features
When active in your vault markdown files, the following features are available:

**Completion:**
- Wiki-link completion: Type `[[` to get suggestions for existing notes
- Tag completion: Type `#` to get suggestions for existing tags
- Minimum 2 characters required to trigger suggestions (reduces noise)

**Navigation & Editing:**
- `gf` - Follow markdown/wiki links to other notes
- `<leader>ch` - Toggle checkboxes ([ ] ↔ [x])
- `<CR>` - Smart action: follows link if on link, toggles checkbox if on checkbox

**UI Enhancements:**
- Visual styling for checkboxes, tags, references, and external links
- Concealing features for cleaner markdown display
- Syntax highlighting improvements for Obsidian-specific elements

**Attachments:**
- `:ObsidianPasteImg` - Paste images from clipboard into notes
- Configured to save images to `assets/imgs/` subdirectory with timestamped names

## Smart Activation System

### Automatic Behavior
The setup includes intelligent automatic activation/deactivation:

- **When entering** a markdown file in `~/.obsidian/**/*.md`:
  - Plugin loads (if not already loaded) via lazy.nvim's loader API
  - obsidian.nvim's internal handler applies workspace config and buffer-local key mappings

- **When leaving** those buffers:
  - Buffer-local mappings are cleared

### Isolation Guarantees
This ensures that outside your vault:
- ✅ 100% standard Neovim/LazyVim experience
- ✅ No Obsidian completion in `.js`, `.ts`, `.py`, `.go`, etc. files
- ✅ No key mapping conflicts with development plugins
- ✅ Your existing workflow remains completely unchanged

### Technical Implementation
The activation/deactivation is handled by autocommands in `obsidian_autocmds.lua`:
- `BufEnter` on `*.md` → `in_vault()` checks if the file's full path starts with the vault root → calls `require("lazy.core.loader").load("obsidian.nvim")` then re-fires BufEnter so obsidian's internal handler activates
- `BufLeave` on `*.md` → if in vault, clears buffer-local mappings
- `VimEnter` (once) → checks if CWD is inside the vault or current file is in vault → loads if so
- Manual control commands available for special cases

For complete command and mapping reference, see the [Obsidian Cheatsheet](./cheatsheets/neovim-obsidian.md).

## Usage Instructions

### In Your Obsidian Vault (`~/.obsidian/**/*.md`)
Once you open a markdown file in your vault, you'll have access to:

**Note Creation:**
- `:ObsidianNew My New Note` → Create a new note
- `:ObsidianNewFromTemplate Meeting` → Create from template
- `:ObsidianTemplate daily` → Insert a template

**Navigation:**
- `:ObsidianQuickSwitch` → Fuzzy find and open notes
- `gf` → Follow link under cursor (works on `[[Wiki Links]]`)
- `:ObsidianBacklinks` → Show notes linking to current note
- `:ObsidianLinks` → Show all links in current note

**Daily Notes & Templates:**
- `:ObsidianToday` → Open/create today's daily note
- `:ObsidianYesterday` → Previous workday's note
- `:ObsidianTomorrow` → Next workday's note
- `:ObsidianDailies -2 1` → List daily notes from 2 days ago to tomorrow

**Tags & Search:**
- `:ObsidianTags #project #meeting` → Show notes with specific tags
- `:ObsidianSearch "search term"` → Search vault contents with ripgrep

**Editing & Maintenance:**
- `<leader>ch` → Toggle checkbox at cursor
- `:ObsidianLinkNew Idea for Feature` → Link selection to new note
- `:ObsidianExtractNote Summary` → Extract selection to new note and link
- `:ObsidianRename New-Name` → Rename note and update all links
- `:ObsidianPasteImg` → Paste image from clipboard

### Outside Your Vault (Development Work)
When editing any file outside `~/.obsidian/**/*.md`:
- ❌ Zero Obsidian features active
- ✅ Standard Vim/Neovim motions work normally
- ✅ Your existing plugins/configurations function unchanged
- ✅ No completion interference in code files
- ✅ No key mapping conflicts

## Manual Control Commands

For special situations (like working with a vault mounted via SSH or outside `~/.obsidian`), you can manually control the features:

- `:ObsidianEnableManual` → Force-enable Obsidian.nvim features in current buffer
- `:ObsidianDisableManual` → Force-disable Obsidian.nvim features in current buffer

These commands are available in any buffer and useful when:
- Working with a vault symlinked or mounted outside `~/.obsidian`
- Temporarily needing Obsidian features in a non-vault markdown file
- Debugging activation/deactivation issues

## Maintenance & Customization

### Changing Vault Location
To use a different vault location:
1. Update the `path` in the `workspaces` array in `obsidian.lua`
2. Update `vault_root` in `obsidian_autocmds.lua`

### Adding Additional Vaults
Configure multiple vaults by adding entries to the `workspaces` array:
```lua
workspaces = {
  {
    name = "personal",
    path = "~/.obsidian",
  },
  {
    name = "work",
    path = "~/work-vault",
  },
}
```

### Adjusting Completion
Modify completion behavior in the plugin opts:
```lua
completion = {
  min_chars = 3,  -- Increase to reduce noise further
},
```

### Updating
Keep your setup current with:
- `:Lazy update` - Updates all plugins including obsidian.nvim
- `:checkhealth obsidian` - Diagnose plugin issues

## Troubleshooting Guide

### Features Not Activating in Vault
**Symptoms:** Completion/mappings not working in `~/.obsidian/*.md` files
**Checks:**
1. Verify you're actually in the vault directory: `:pwd`
2. Confirm filetype is markdown: `:set ft?` should show `markdown`
3. Look for initialization messages when opening the file
4. Check if plugin loaded: `:Lazy` → look for obsidian.nvim

### Completion Showing in Code Files
**Symptoms:** Seeing Obsidian suggestions in `.js`, `.ts`, etc. files
**Checks:**
1. Verify autocommands are active: `:autocmd BufEnter`
2. Check that obsidian completion source is properly removed when leaving vault
3. Ensure no other plugin is injecting obsidian completion

### Key Mappings Not Working
**Symptoms:** `gf`, `<leader>ch`, or `<CR>` not behaving as expected
**Checks:**
1. Verify buffer-local mappings: `:verbose map gf`
2. Check for mapping conflicts with other plugins
3. Confirm you're in a markdown file in your vault when testing
4. Try disabling other plugins temporarily to isolate conflicts

### Manual Commands Not Available
**Symptoms:** `:ObsidianEnableManual` not recognized
**Checks:**
1. Verify autocommand file is sourced: check `:messages` for errors on startup
2. Confirm file exists at correct path
3. Check for Lua syntax errors in the autocommand file

## Integration Notes

### Compatibility with LazyVim
- Designed to work alongside existing LazyVim configuration
- No changes required to your current keymaps, options, or other plugins
- Compatible with LazyVim's automatic plugin updating (`checker = true`)
- Works with LazyVim's performance optimizations

### Git Integration
Standard Git workflows work normally:
1. Initialize repo in vault: `cd ~/.obsidian && git init`
2. Create `.gitignore` to exclude cache/temporary files
3. Use standard Git commands or Neovim Git plugins (vim-fugitive, gitsigns, etc.)
4. The plugin works regardless of Git status

### Updates & Maintenance
- Plugin updates handled via standard LazyVim mechanisms
- Documentation should be updated when configuration changes significantly
- Consider adding this documentation to your regular backup/sync routine

---

*Last updated: $(date)*  
*Part of personal dotfiles configuration*