#!/bin/bash
set -e

# Populate rclone config from KeePassXC database
"$DOTFILES_HOME/bin/update-secrets" rclone
