#!/bin/bash
timestamp=$(date +%s)
sudo -E borg create --progress --exclude-from=/home/tristan/Projects/dotfiles/arch/backup_excludes.txt "/backuprepo/::system-$timestamp" /
sudo rclone --config /home/tristan/.config/rclone/rclone.conf sync -P /backuprepo bernard:/media/disk2/backup/"$(uname -n)"
sudo rclone --config /home/tristan/.config/rclone/rclone.conf sync --transfers=10 -P /backuprepo system-backup:thavelick-backup/"$(uname -n)"
