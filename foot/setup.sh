#!/bin/sh
mkdir -p "$HOME/.config/foot"
ln -svf "$DOTFILES_HOME/foot/foot.ini" "$HOME/.config/foot/foot.ini"
mkdir -p "$HOME/.local/share/foot"
ln -svnf "$DOTFILES_HOME/foot/themes/" "$HOME/.local/share/foot/themes"

# Create default theme config (dark mode) in case darkman hasn't run yet
if [ ! -f "$HOME/.local/share/foot/foot-theme.ini" ]; then
    echo "# Foot theme setting - managed by darkman, not in source control" > "$HOME/.local/share/foot/foot-theme.ini"
    echo "initial-color-theme=1" >> "$HOME/.local/share/foot/foot-theme.ini"
fi
