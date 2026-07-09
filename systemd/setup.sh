#!/bin/sh
set -e

# Create systemd user config directory
mkdir -p "$HOME/.config/systemd/user"

# Symlink systemd user services
ln -svf "$DOTFILES_HOME/systemd/user/monitor-hotplug.service" "$HOME/.config/systemd/user/monitor-hotplug.service"
ln -svf "$DOTFILES_HOME/systemd/user/kiwix.service" "$HOME/.config/systemd/user/kiwix.service"
ln -svf "$DOTFILES_HOME/systemd/user/nextcloud-sync-check.service" "$HOME/.config/systemd/user/nextcloud-sync-check.service"
ln -svf "$DOTFILES_HOME/systemd/user/nextcloud-sync-check.timer" "$HOME/.config/systemd/user/nextcloud-sync-check.timer"

# Reload systemd and enable services
systemctl --user daemon-reload
systemctl --user enable monitor-hotplug.service
systemctl --user enable kiwix.service
systemctl --user enable nextcloud-sync-check.timer

# Start services if not already running
systemctl --user is-active --quiet monitor-hotplug.service || systemctl --user start monitor-hotplug.service
systemctl --user is-active --quiet kiwix.service || systemctl --user start kiwix.service
systemctl --user is-active --quiet nextcloud-sync-check.timer || systemctl --user start nextcloud-sync-check.timer