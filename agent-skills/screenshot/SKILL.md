---
name: screenshot
description: Read the most recent screenshot(s) the user took. Use when the user references "the screenshot I took", "my latest screenshot", "look at the screenshot", "the 3 screenshots I just took", "a few screenshots", or similar phrasings that imply opening their most recent screen capture(s) without specifying a path.
argument-hint: "[count]"
---

Resolve the user's most recent screenshot(s) and Read them.

## 1. Determine count

How many of the newest screenshots to read:

- If `$ARGUMENTS` contains a number, use that.
- Otherwise, parse the user's message:
  - Explicit number ("the 3 screenshots", "last 2") → that number.
  - "a couple" → 2.
  - "a few", "several", "some" → 3.
  - Singular ("the screenshot", "my latest screenshot") or unstated → 1.

## 2. Resolve the directory

In order:

1. If `$SCREENSHOT_DIR` is set, use it. If it's set but the path doesn't exist, say so and stop — do not fall back, that would hide typos.
2. Otherwise, pick by Platform from your environment context:
   - `darwin` → `~/Desktop`
   - `linux` → `~/Pictures`

## 3. Find the newest N images

```bash
find "$dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' \) -print0 \
  | xargs -0 ls -t \
  | head -n "$count"
```

If the directory exists but has no matching images, say so and stop. If the user asked for N but only M < N exist, read what's there and mention the shortfall.

## 4. Read each file

Use the Read tool on each path (newest first). Briefly state filename + mtime for each so the user can sanity-check you grabbed the right shots.
