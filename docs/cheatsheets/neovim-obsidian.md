# Obsidian.nvim Cheatsheet

Quick reference for all available Obsidian.nvim commands, mappings, and workflows when working in your Obsidian vault (`~/.obsidian/**/*.md`).

*Note: All commands and mappings below are only active in markdown files within your configured vault(s).*

## 📝 Note Creation & Editing

| Command | Description |
|---------|-------------|
| `:ObsidianNew [title]` | Create a new note. If `[title]` is omitted, you'll be prompted for a title. |
| `:ObsidianNewFromTemplate [title]` | Create a new note from a template. Prompts for template selection if `[title]` omitted. |
| `:ObsidianTemplate [name]` | Insert a template from your templates folder at the current cursor position. |
| `:ObsidianExtractNote [title]` | Extract visually selected text into a new note and link to it from the current location. |
| `:ObsidianRename [newname] [--dry-run]` | Rename the current note and update all links/backlinks across the vault. Use `--dry-run` to preview changes. |

## 🔗 Navigation & Linking

| Command | Description |
|---------|-------------|
| `:ObsidianQuickSwitch` | Fuzzy find and open/open a note in your vault using your preferred picker (telescope by default). |
| `:ObsidianFollowLink [vsplit\|hsplit]` | Follow the link under the cursor. Optionally open in vertical/horizontal split. |
| `:ObsidianBacklinks` | Show a list of all notes that link to the current note (backlinks). |
| `:ObsidianLinks` | Show a list of all links contained in the current note. |
| `:ObsidianLink [query]` | Link the current visual selection to a note. If `[query]` omitted, uses selected text as query. |
| `:ObsidianLinkNew [title]` | Create a new note and link it to the current visual selection. Prompts for title if omitted. |

## 📅 Daily Notes & Templates

| Command | Description |
|---------|-------------|
| `:ObsidianToday [offset]` | Open/create today's daily note. Use `[offset]` for relative dates (e.g., `-1` for yesterday). |
| `:ObsidianYesterday` | Open/create the daily note for the previous working day. |
| `:ObsidianTomorrow` | Open/create the daily note for the next working day. |
| `:ObsidianDailies [offset...]` | Open a picker list of daily notes. Provide offsets to show a range (e.g., `-2 1` for yesterday to tomorrow). |

## 🏷️ Tags & Search

| Command | Description |
|---------|-------------|
| `:ObsidianTags [tag...]` | Show a picker list of all occurrences of the specified tag(s). If no tags given, shows all tags in vault. |
| `:ObsidianSearch [query]` | Search for (or create) notes matching `[query]` using ripgrep with your preferred picker. |

## 🗂️ Workspace & Vault

| Command | Description |
|---------|-------------|
| `:ObsidianWorkspace [name]` | Switch to a different configured workspace/vault. |
| `:ObsidianOpen [query]` | Open the current note (or note matching `[query]`) in the Obsidian application. |

## 🖼️ Attachments

| Command | Description |
|---------|-------------|
| `:ObsidianPasteImg [imgname]` | Paste an image from the clipboard into the current note at the cursor position. The image is saved to your vault and a markdown image link is inserted. |

## 🔧 Maintenance

| Command | Description |
|---------|-------------|
| `:ObsidianTOC` | Load the table of contents of the current note into a picker list for quick navigation. |

## ⚙️ Manual Control (Our Additions)

| Command | Description |
|---------|-------------|
| `:ObsidianEnableManual` | Force-enable Obsidian.nvim features in the current buffer. Useful for SSH vaults or temporary work. |
| `:ObsidianDisableManual` | Force-disable Obsidian.nvim features in the current buffer. |

## ⌨️ Key Mappings

*These mappings are **buffer-local** and only active in markdown files within your vault(s):*

| Key | Action | Description |
|-----|--------|-------------|
| `gf` | `ObsidianFollowLink` | Follow markdown/wiki link under cursor |
| `<leader>ch` | `ObsidianToggleCheckbox` | Toggle checkbox state ([ ] ↔ [x]) |
| `<cr>` | `ObsidianSmartAction` | Follow link if on link, toggle checkbox if on checkbox |

*Note: `<leader>` is typically `\` or `,` depending on your LazyVim configuration.*

## 💡 Common Workflows

### Creating a Linked Note
1. Select text you want to use as note title/link text
2. Run `:ObsidianLinkNew My New Note`
3. Press `<CR>` on the newly created link to jump to and edit the new note

### Quick Daily Journal
1. Run `:ObsidianToday`
2. Write your journal entry
3. Use `<leader>ch` to toggle task boxes as you complete items
4. Use `[[` to link to related projects or people as you mention them

### Finding Related Notes
1. Position cursor on a tag (`#project`) or wiki link (`[[Meeting Notes]]`)
2. Run `:ObsidianTags` or `:ObsidianBacklinks` to see related notes
3. Use `<CR>` in the picker to jump to selected result
4. Use `<C-x>` or `<C-l>` (configured in picker) to insert links/tags

### Extracting Thoughts
1. Select a paragraph or section you want to separate
2. Run `:ObsidianExtractNote Summary of Key Points`
3. A new note is created with the selected content and linked from the original

### Linking to Existing Content
1. Select text you want to turn into a link
2. Run `:ObsidianLinked Existing Note Title` (or just `:ObsidianLinked` and select from picker)
3. The selected text becomes a link to the target note

## 📋 Template Usage

To use templates effectively:
1. Create template files in your vault's `templates/` folder
2. Use template variables: `{{title}}`, `{{date}}`, `{{time}}`, `{{id}}`
3. Add custom substitutions in your plugin config if needed
4. Insert with `:ObsidianTemplate` or create new from template with `:ObsidianNewFromTemplate`

## 🖼️ Image Handling

When using `:ObsidianPasteImg`:
- Images are saved to `assets/imgs/` by default (configurable)
- Filenames are timestamped to prevent conflicts: `1623456789-image.png`
- Markdown syntax is automatically inserted: `![1623456789](assets/imgs/1623456789-image.png)`
- You can specify a custom name: `:ObsidianPasteImg my-custom-name.png`

## 🔍 Search Tips

With `:ObsidianSearch`:
- Use regular expressions for advanced searching
- Search respects your vault's folder structure
- Results show preview snippets with matches highlighted
- `<CR>` opens selected result in current buffer
- `<C-v>` opens in vertical split, `<C-s>` in horizontal split (telescope defaults)

## ⚙️ Configuration Locations

To modify this behavior:
- **Plugin settings**: `lua/plugins/obsidian.lua`
- **Activation logic**: `lua/config/obsidian_autocmds.lua`
- **Key mappings**: Check your LazyVim keymaps (`lua/config/keymaps.lua`)
- **Templates**: Located in `~/.obsidian/templates/` by default

---

*Cheatsheet for Obsidian.nvim integration with LazyVim*  
*Keep this reference handy while working in your vault!*