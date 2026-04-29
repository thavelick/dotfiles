# Kiwix Server Setup (Arch Linux)

`kiwix-serve` runs as a systemd user unit on `localhost:8080`, serving every
`*.zim` file in `~/kiwix/`.

## Install

```bash
sudo pacman -S --needed kiwix-tools aria2
```

## ZIM files

ZIMs live in `~/kiwix/`. The systemd unit reads `~/kiwix/library.xml`, which is
maintained with `kiwix-manage` — this lets in-progress aria2 downloads sit
alongside the served collection without breaking the server.

Download new ZIMs with resume support, then register once complete:

```bash
cd ~/kiwix
aria2c -c -x 8 -s 8 https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2026-02.zim
kiwix-manage ~/kiwix/library.xml add ~/kiwix/wikipedia_en_all_maxi_2026-02.zim
systemctl --user restart kiwix.service
```

Browse the catalog at <https://download.kiwix.org/zim/>.

To rebuild `library.xml` from scratch (e.g. after pruning ZIMs):

```bash
cd ~/kiwix
rm library.xml
for z in *.zim; do
  [ -f "$z.aria2" ] && continue   # skip in-progress aria2 downloads
  kiwix-manage library.xml add "$z"
done
systemctl --user restart kiwix.service
```

`~/kiwix/*.zim` is excluded from borg backups via
`arch/backup_excludes.txt` — the Wikipedia ZIM alone is ~115 GB.

## systemd user service

The unit lives at `systemd/user/kiwix.service` in this dotfiles repo and is
symlinked into `~/.config/systemd/user/` by `systemd/setup.sh`.

To enable it on a fresh machine:

```bash
systemctl --user daemon-reload
systemctl --user enable --now kiwix.service
```

The service runs only while a user session is active, which is fine on a
single-user laptop. On a headless or multi-user box, run
`sudo loginctl enable-linger "$USER"` so it persists across logout.

Verify:

```bash
curl -sI http://localhost:8080/
systemctl --user status kiwix.service
```

After dropping a new ZIM into `~/kiwix/`:

```bash
systemctl --user restart kiwix.service
```

Access the library at <http://localhost:8080>.
