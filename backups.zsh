#!/bin/zsh
timestamp=$(date +%s)
sudo -E borg create --progress --exclude-from=/home/tristan/Projects/dotfiles/arch/backup_excludes.txt "/backuprepo/::system-$timestamp" /



