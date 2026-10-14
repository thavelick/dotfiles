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

URL_BEFORE_PUNCTUATION = re.compile(
    r"""
    (?<![<(])            # not already in <...>, and not a markdown link target ](...)
    \b
    (https?://[^\s<>]+?) # the URL: no whitespace or angle brackets; lazy, so
                         # it stops before the punctuation instead of eating it
    ([.,;:!?]+)          # the punctuation run kitty would otherwise include
    (?=\s|$)             # ...which must end the word, so a "." inside the
                         # URL (example.com) doesn't count
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
