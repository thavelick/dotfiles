#!/bin/sh
set -e

# Create systemd user config directory
mkdir -p "$HOME/.config/systemd/user"

# Symlink systemd user services
ln -svf "$DOTFILES_HOME/systemd/user/monitor-hotplug.service" "$HOME/.config/systemd/user/monitor-hotplug.service"

# Reload systemd and enable service
systemctl --user daemon-reload
systemctl --user enable monitor-hotplug.service

# Start service if not already running
systemctl --user is-active --quiet monitor-hotplug.service || systemctl --user start monitor-hotplug.service