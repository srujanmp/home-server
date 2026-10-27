# home-server: instructions for coding agents

Goal: one public address, `https://home.solulu.dev`, on the owner's static public IP (no NAT, ports can be forwarded).
`/` is a login-protected dashboard; apps hang off paths (`/movies`, `/tv`, `/downloads`, ...). Simple to add a new
app: one compose service + one Caddy block. No Cloudflare Tunnel (old `tunnel1` is unused; ignore it).
The solulu Worker (`Desktop\solulu`) must keep working: only add the `home` DNS record, never touch other records.

## Hard rules
- Never write the router password, API keys, DDNS tokens or app passwords into any file or chat. The router
  password was pasted in chat once: tell the owner to change it. Secrets go in a gitignored `.env`.
- Router (192.168.0.1:10000): ask the owner before changing it. Forward only: 80 and 443 (-> Caddy), 25565 (Minecraft,
  only when that server exists). Never forward qBittorrent, Sonarr, Radarr, Prowlarr, Proxmox (8006) or SSH.
- DNS: `home` A record -> public IP, **DNS only (grey cloud)**. Proxying video through Cloudflare breaches its terms.
- Everything behind auth. No app is reachable without passing Authelia (forward auth in Caddy), with 2FA.
- Legal content only; do not add indexer lists or release-site links.
- Disk: owner's laptop C: was 97% full. Check free space before any download; media goes on a big dedicated disk.

## Stack (all current, open source)
| Role | Tool | URL path |
|---|---|---|
| Reverse proxy + auto HTTPS | Caddy | n/a |
| Login + 2FA (SSO) | Authelia | `/auth` |
| Dashboard | Homepage (gethomepage) | `/` |
| Watch | Jellyfin | `/movies` (base URL set to it) |
| Movies / TV automation | Radarr / Sonarr | `/radarr`, `/sonarr` |
| Indexers | Prowlarr | `/prowlarr` |
| Downloader | qBittorrent behind Gluetun (VPN) | `/downloads` |
| Requests (optional) | Jellyseerr | `/request` |
| Subtitles (optional) | Bazarr | `/bazarr` |
| Quality profiles as code | Recyclarr | n/a |
| Updates | Diun or manual (Watchtower is archived, do not use) | n/a |
| Files (optional) | Filebrowser Quantum | `/files` |
| Minecraft (later) | itzg/minecraft-server (Paper), port 25565 | n/a |

Path routing needs each app's "URL base" setting (Sonarr/Radarr/Prowlarr/qBittorrent/Jellyfin all have one).
If an app breaks under a path, fall back to a subdomain (`radarr-home.solulu.dev`; free certs only cover one level).

## Folder layout (TRaSH Guides: https://trash-guides.info/File-and-Folder-Structure/)
Everything under ONE filesystem so hardlinks and instant moves work. Do not use exFAT.
```
data
├── torrents/{movies,tv}
├── usenet/{incomplete,complete/{movies,tv}}   (only if usenet is added)
└── media/{movies,tv}
```
- Each container mounts the lowest folder it needs but keeps the same `/data/...` path (e.g. qBittorrent gets
  `/data/torrents`; Radarr/Sonarr/Jellyfin get `/data`).
- One user per app + shared group, `UMASK 002`, dirs 775, files 664. Use `PUID`/`PGID` env OR `user:`, never both.
  Never UMASK 000.
- Verify hardlinks work (TRaSH "check if hardlinks are working") before declaring the stack done.
- Radarr/Sonarr: follow the TRaSH naming scheme, quality profiles and custom formats via Recyclarr
  (https://trash-guides.info/Radarr/ , /Sonarr/). Do not hand-click what Recyclarr can configure.
- Do not edit hardlinked files after import (changes the seeding copy).

## Host options (open decision: ask the owner, recommendation first)
1. **Ubuntu Server + Docker Compose** on a machine that stays on. Recommended: fewest layers, easiest to debug.
2. **Proxmox VE 9.x** (https://www.proxmox.com/en/downloads): only for a dedicated spare PC. Run one LXC (or VM) with
   Docker inside; the media disk goes to that guest as ONE mount so hardlinks hold. LXC shares the iGPU for Jellyfin
   transcoding. Proxmox wipes the disk it installs on.
3. **This Windows laptop (ASUS TUF F15):** works through Docker Desktop/WSL2, but keep `data` inside the WSL ext4
   disk (not `/mnt/c`, which breaks hardlinks and is slow), and the PC must stay awake with lid-close sleep disabled.
   Use only to trial the stack.
Also needed: DHCP reservation for the server's LAN IP; UPS or at least auto-power-on after outage.

## Build order
1. Confirm host + media disk with the owner. Create `compose.yaml`, `.env.example`, `Caddyfile`, `authelia/` config.
2. Bring up Caddy + Authelia + Homepage first; test `/` login from LAN, then forward 80/443 and test from mobile data.
3. Add Jellyfin, then qBittorrent+Gluetun, Prowlarr, Radarr, Sonarr; wire them with API keys from `.env`; run Recyclarr.
4. Hardlink test, then one test download of a legal/public-domain file, then Jellyseerr/Bazarr.
5. Minecraft last. Back up config volumes (not media).

## Done checklist
Nothing reachable without login; only 80/443(/25565) forwarded; `.env` gitignored; secret scan clean; hardlinks verified;
`README.md` has the owner-facing steps (how to add a new app). Update this file with what is live and open decisions.

## References
https://trash-guides.info/ · https://docs.linuxserver.io/ · https://www.authelia.com/ · https://caddyserver.com/docs/
