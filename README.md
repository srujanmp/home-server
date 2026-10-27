# home-server

Self-hosted movies + downloads on this PC, reachable from anywhere behind a login. Separate from the solulu
Worker: it only adds two new hostnames, so nothing existing changes.

| URL | App | Local port |
|---|---|---|
| https://home.solulu.dev | Jellyfin (watch) | 8096 |
| https://get-home.solulu.dev | qBittorrent (downloads) | 8080 |

Names are one level under solulu.dev because the free Cloudflare certificate does not cover `a.home.solulu.dev`.

## Setup (once)
1. Free space first: C: is ~97% full. Put the library on another drive (`-Media D:\Media`).
2. Run in PowerShell: `.\setup.ps1 -Media D:\Media`
   - installs cloudflared, Jellyfin, qBittorrent (winget); logs in to Cloudflare in a browser tab
   - creates tunnel `home`, DNS records for both names, and a Windows service so it starts at boot
3. Add the login (dashboard, free): Zero Trust -> Access -> Applications -> Add -> Self-hosted.
   Add both hostnames, policy Allow -> Emails -> your email (one-time code login). Do this BEFORE opening the URLs.
4. Open http://localhost:8096 once to create the Jellyfin admin user; point the Movies library at `D:\Media\Movies`.
   Open http://localhost:8080, change the qBittorrent password, set save path to `D:\Media\Movies`.

Delete the unused `tunnel1` in the dashboard if you like; this uses a new tunnel called `home`.

## Minecraft
A Cloudflare Tunnel cannot carry Minecraft for players without extra software. Use one of:
- playit.gg (free, no router changes): install its agent, it gives a public address.
- Port forward 25565 on the router (needs a public IP, exposes your home IP).
Server: PaperMC jar + `java -jar paper.jar nogui` in `minecraft\`. Not scripted yet.

## Notes
- Streaming video through Cloudflare can breach their terms (non-HTML content). For personal use the risk is low,
  but for heavy use prefer Tailscale for Jellyfin and keep the tunnel for the login-protected admin pages.
- Only download content you have the right to.
- The PC must be on for any of this to work.
