#!/bin/bash
set -e

# Helper function to disable a symbolic hotkey
disable_hotkey() {
  local hotkey_id=$1
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$hotkey_id" "
  <dict>
    <key>enabled</key><false/>
  </dict>
"
}

# Remap Caps Lock to Control
# HID usage codes: 30064771296 = Caps Lock, 30064771129 = Control
KEYBOARD_ID="5426-269-0"
if system_profiler SPUSBDataType 2>/dev/null | grep -q "$KEYBOARD_ID" || \
   defaults -currentHost read -g 2>/dev/null | grep -q "com.apple.keyboard.modifiermapping.$KEYBOARD_ID"; then
  defaults -currentHost write -g com.apple.keyboard.modifiermapping.$KEYBOARD_ID -array-add '
<dict>
  <key>HIDKeyboardModifierMappingDst</key>
  <integer>30064771129</integer>
  <key>HIDKeyboardModifierMappingSrc</key>
  <integer>30064771296</integer>
</dict>
'
else
  echo "Warning: Keyboard $KEYBOARD_ID not found. Caps Lock mapping not applied." >&2
  echo "Run this to find your keyboard ID:" >&2
  echo "  defaults -currentHost read -g | grep -i keyboard" >&2
fi

# Disable Ctrl+Space keyboard layout switching (conflicts with tmux prefix key)
# 60 = Select the previous input source
# 61 = Select next source in Input menu
disable_hotkey 60
disable_hotkey 61

# Disable Mission Control Ctrl+Arrow shortcuts to allow word jumping
# 79 = Move left a space (Ctrl+Left Arrow)
# 81 = Move right a space (Ctrl+Right Arrow)
disable_hotkey 79
disable_hotkey 81

# Create DefaultKeyBinding.dict symlink for Ctrl+Arrow word jumping
mkdir -p ~/Library/KeyBindings
ln -svf "$DOTFILES_HOME/mac/DefaultKeyBinding.dict" ~/Library/KeyBindings/DefaultKeyBinding.dict

# Restart preferences daemon to apply changes
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
