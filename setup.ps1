param([Parameter(Mandatory)][string]$Media)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force "$Media\Movies" | Out-Null
foreach ($id in 'Cloudflare.cloudflared','Jellyfin.Server','qBittorrent.qBittorrent') { winget install -e --id $id --accept-source-agreements --accept-package-agreements }
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
cloudflared tunnel login                      # pick solulu.dev in the browser
cloudflared tunnel create home
$id = (cloudflared tunnel list -o json | ConvertFrom-Json | Where-Object name -eq 'home').id
$dir = "$env:USERPROFILE\.cloudflared"
(Get-Content "$PSScriptRoot\config.yml.template") -replace '__TUNNEL_ID__',$id -replace '__CREDS__',"$dir\$id.json" | Set-Content "$dir\config.yml"
cloudflared tunnel route dns home home.solulu.dev
cloudflared tunnel route dns home get-home.solulu.dev
cloudflared service install                   # needs an admin PowerShell
Write-Host "Done. Now add the Access login policy (README step 3) before using the URLs."
