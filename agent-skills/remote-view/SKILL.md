---
name: remote-view
description: Serve a local HTML file over the LAN with a Python web server and hand back a clickable link, for when the user is on a different machine than the one Claude runs on. Use when the user says "remote view", "let me view this from my laptop/phone", "serve this so I can open it", or asks for a link to an HTML file they can't open locally.
argument-hint: "[path-to-html-file]"
---

The user is sitting at a different machine from the one you run on, so `file://` paths and `localhost` links are useless to them. Serve the file on the LAN and give them a URL that works from their machine.

## 1. Resolve the file

- Use the path in `$ARGUMENTS`, or the HTML file the user named. If it's ambiguous (e.g. "the report" with several candidates), ask.
- Make it absolute and confirm it exists. Split it into `dir` (its directory) and `name` (its basename).

## 2. Choose what to serve

`http.server` exposes **everything** under the directory it serves to anyone on the network.

- If `dir` is a narrow output/scratch directory, serve it directly, so relative assets (CSS, JS, images) keep working.
- If `dir` is broad or sensitive — `$HOME`, `~/Desktop`, `~/Downloads`, a repo root, anything with `.env`/keys in it — copy the file (plus any local assets it references) into `$(mktemp -d)` and serve that instead. Tell the user you did.

If you already started a server for this same directory earlier in the session and it's still running, reuse it: skip to step 5 with the existing port.

## 3. Find the LAN IP

Pick by Platform from your environment context:

- `darwin`:
  ```bash
  iface=$(route -n get default | awk '/interface:/ {print $2}')
  ip=$(ipconfig getifaddr "$iface")
  ```
- `linux`:
  ```bash
  ip=$(ip route get 1.1.1.1 | awk '{for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1)}')
  ```

If that comes back empty, fall back to listing `inet` addresses (`ifconfig` / `ip -4 addr`) and pick the private one (`192.168.*`, `10.*`, `172.16–31.*`). If there are several plausible ones, list them all as links rather than guessing.

If `tailscale` is on PATH, also grab `tailscale ip -4` — that link works when the user isn't on the same LAN.

## 4. Start the server

Pick a free port, then launch with the Bash tool's `run_in_background: true` so it outlives the call:

```bash
port=$(python3 -c 'import socket; s = socket.socket(); s.bind(("", 0)); print(s.getsockname()[1])')
```

```bash
python3 -m http.server "$port" --bind 0.0.0.0 --directory "$dir"
```

## 5. Verify and hand over the link

Build the URL with the filename URL-encoded:

```bash
url_path=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$name")
url="http://$ip:$port/$url_path"
curl -fsS -o /dev/null -w '%{http_code}\n' "$url"
```

A `200` means it's up. If it fails, check the background task's output before reporting anything.

Then reply with:

- The link(s) as clickable markdown — LAN first, Tailscale second if you have one.
- What directory is being served.
- How to stop it: it's a background task you can kill on request (or `pkill -f "http.server $port"`).
- On macOS, if the user says it won't load, the first-run firewall prompt for Python may be blocking incoming connections.
