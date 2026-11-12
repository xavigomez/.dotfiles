#!/bin/zsh

# Native menu shortcuts, applied by install.sh or manually. English menus only.
# macOS persists these preferences; nothing runs at login or in the background.
set -eu

if (( $# > 1 )) || [[ ${1:-apply} != apply ]]; then
  print -ru2 -- 'Usage: ./macos.sh [apply]'
  exit 2
fi
[[ "$OSTYPE" == darwin* ]] || { print -ru2 -- 'This script requires macOS.'; exit 1; }
(( EUID != 0 )) || { print -ru2 -- 'Run as your normal user, not with sudo.'; exit 1; }
version=$(/usr/bin/sw_vers -productVersion)
(( ${version%%.*} >= 15 )) || { print -ru2 -- 'Requires macOS 15 or later.'; exit 1; }

# ^ = Control, ~ = Option; \033 separates menu levels. Merge only these entries.
# Browsers use Enter/Exit Full Screen; Ghostty calls it Toggle Full Screen.
/usr/bin/defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
  $'\033Window\033Fill' $'^~\r' \
  $'\033Window\033Move & Resize\033Left' $'^~\uF702' \
  $'\033Window\033Move & Resize\033Right' $'^~\uF703' \
  'Enter Full Screen' '^~f' \
  'Exit Full Screen' '^~f' \
  'Toggle Full Screen' '^~f'

print -r -- 'Native window shortcuts configured. Reopen affected apps to activate changes.'
