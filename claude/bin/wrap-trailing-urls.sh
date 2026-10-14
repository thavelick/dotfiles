#!/bin/sh
# Wrap URLs directly followed by punctuation (.,;:!?) in angle brackets:
# "see https://x/1." becomes "see <https://x/1>." so clicking the link in
# kitty doesn't grab the punctuation.
#
# Registered as a MessageDisplay hook. Display-only: the stored message and
# what the model sees are untouched. Prints nothing when there's nothing to
# change, so a failure here leaves the original text on screen.
set -eu

# The trailing x keeps $( ) from stripping the delta's final newlines.
delta=$(jq -j '.delta // ""'; printf x)
delta=${delta%x}

# A URL followed by trailing punctuation and then whitespace or end of text.
# Skips URLs already in <...> and markdown link targets ](...).
fixed=$(printf '%s' "$delta" | perl -CSD -0pe 's{(?<![<(])\b(https?://[^\s<>]+?)([.,;:!?]+)(?=\s|$)}{<$1>$2}g'; printf x)
fixed=${fixed%x}

[ "$fixed" != "$delta" ] || exit 0

printf '%s' "$fixed" | jq -Rs '{hookSpecificOutput: {hookEventName: "MessageDisplay", displayContent: .}}'
