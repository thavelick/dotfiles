#!/usr/bin/env python3
"""Wrap URLs directly followed by punctuation (.,;:!?) in angle brackets.

"see https://x/1." becomes "see <https://x/1>." so clicking the link in
kitty doesn't grab the punctuation.

Registered as a MessageDisplay hook. Display-only: the stored message and
what the model sees are untouched. Prints nothing when there's nothing to
change, so a failure here leaves the original text on screen.
"""

import json
import re
import sys

# Matches a URL and the punctuation right after it, capturing them separately
# so the URL can be wrapped and the punctuation left outside.
#
# URLs already in <...> are skipped, as are markdown link targets ](...),
# which are already links. The URL match is lazy so it stops before the
# punctuation instead of swallowing it, and the punctuation must be followed
# by whitespace so a "." inside the URL (example.com) doesn't count.
URL_BEFORE_PUNCTUATION = re.compile(
    r"""
    (?<![<(])       # the character before is not "<" or "("
    \b              # starting at a word boundary
    (               # capture group 1, the URL:
      https?://     #   "http://" or "https://"
      [^\s<>]+?     #   then one or more characters that aren't whitespace,
                    #   "<" or ">", as few as possible
    )
    ([.,;:!?]+)     # capture group 2: one or more of . , ; : ! ?
    (?=\s|$)        # followed by whitespace or the end of the text
    """,
    re.VERBOSE,
)


def main():
    delta = json.load(sys.stdin).get("delta", "")
    fixed = URL_BEFORE_PUNCTUATION.sub(r"<\1>\2", delta)
    if fixed == delta:
        return
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "MessageDisplay",
                "displayContent": fixed,
            }
        },
        sys.stdout,
    )


if __name__ == "__main__":
    main()
