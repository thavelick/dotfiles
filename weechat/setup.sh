#!/bin/bash
set -e

# Populate ~/.config/weechat/sec.conf (Libera password) from KeePassXC database
"$DOTFILES_HOME/bin/update-secrets" weechat

if pgrep -x weechat >/dev/null; then
  echo "Quit WeeChat first; it overwrites its config files on exit." >&2
  exit 1
fi

# ${raw:...} keeps WeeChat from expanding the secure data refs at setup time;
# they are expanded on connect instead.
weechat-headless --no-connect \
  -r '/set irc.server_default.nicks "Natris1979"' \
  -r '/set irc.server_default.username "natris"' \
  -r '/set irc.server_default.realname "Natris"' \
  -r '/server add libera irc.libera.chat/6697 -tls' \
  -r '/set irc.server.libera.sasl_username "Natris1979"' \
  -r '/set irc.server.libera.sasl_password "${raw:${sec.data.libera}}"' \
  -r '/server add twitch irc.chat.twitch.tv/6697 -tls' \
  -r '/set irc.server.twitch.password "${raw:oauth:${sec.data.twitch}}"' \
  -r '/set irc.server.twitch.nicks "natris1979"' \
  -r '/set irc.server.twitch.username "natris1979"' \
  -r '/set irc.server.twitch.realname "natris1979"' \
  -r '/set irc.server.twitch.capabilities "*,twitch.tv/tags,twitch.tv/commands,twitch.tv/membership"' \
  -r '/filter add twitch_joinquit irc.twitch.* irc_join,irc_part,irc_quit *' \
  -r '/quit'
