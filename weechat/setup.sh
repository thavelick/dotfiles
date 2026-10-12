#!/bin/bash
set -e

if pgrep -x weechat >/dev/null; then
  echo "Quit WeeChat first; it overwrites its config files on exit." >&2
  exit 1
fi

# Populate ~/.config/weechat/sec.conf (Libera password) from KeePassXC database
"$DOTFILES_HOME/bin/update-secrets" weechat

# The Twitch password is set later by `twitch-token`, since the token expires.
# ${raw:...} keeps WeeChat from expanding the secure data ref at setup time;
# it is expanded on connect instead.
# shellcheck disable=SC2016  # WeeChat ${raw:...} syntax, not shell expansion
weechat-headless --no-connect \
  -r '/set irc.server_default.nicks "Natris1979"' \
  -r '/set irc.server_default.username "natris"' \
  -r '/set irc.server_default.realname "Natris"' \
  -r '/server add libera irc.libera.chat/6697 -tls' \
  -r '/set irc.server.libera.sasl_username "Natris1979"' \
  -r '/set irc.server.libera.sasl_password "${raw:${sec.data.libera}}"' \
  -r '/server add twitch irc.chat.twitch.tv/6697 -tls' \
  -r '/set irc.server.twitch.nicks "natris1979"' \
  -r '/set irc.server.twitch.username "natris1979"' \
  -r '/set irc.server.twitch.realname "natris1979"' \
  -r '/set irc.server.twitch.capabilities "*,twitch.tv/tags,twitch.tv/commands,twitch.tv/membership"' \
  -r '/filter add twitch_joinquit irc.twitch.* irc_join,irc_part,irc_quit *' \
  -r '/quit'
