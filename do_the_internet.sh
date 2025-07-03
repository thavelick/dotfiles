#!/bin/sh

# # Sync offpunk
cd "$HOME"/src/AV-98-offline || exit
python3 offpunk.py --sync

# Sync email
/usr/sbin/mbsync primary

# Send email
/usr/share/doc/msmtp/msmtpqueue/msmtp-runqueue.sh

