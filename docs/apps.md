# Apps

Defined in `apps/base/<name>/`, enabled by listing them in [`apps/mini/kustomization.yaml`](../apps/mini/kustomization.yaml).

| App | URL | Purpose |
| --- | --- | --- |
| Homepage | `https://homepage.local` | Dashboard — app links, system stats, service health |
| Overseerr | `https://overseerr.local` | Media requests and discovery for Plex |
| Radarr | `https://radarr.local` | Movie management |
| Sonarr | `https://sonarr.local` | TV management |
| Transmission | `https://transmission.local` | Torrent client used by Radarr/Sonarr |
| Yamtrack | `https://yam.local` | Media tracker (SQLite at `/var/lib/yamtrack/db`) |
| Plex | `http://plex.local:32400/web/` | Media server — **disabled by default** |
| Discord | — | Bot, no ingress — **disabled by default** |

Plex takes its own MetalLB IP (`plex_lb_ip`, default `192.168.0.221`) and bypasses Traefik entirely: it handles its own TLS and does not sit well behind a reverse proxy.

## Enabling a disabled app

Uncomment it in `apps/mini/kustomization.yaml` and push. Both have prerequisites first.

### Plex

Needs its hostPath directories present on the node and a claim token.

Directory layout under `/mnt/plex`:

```text
/mnt/plex/
├── downloads/          # Transmission temp storage
│   ├── incomplete/
│   └── complete/
├── media/
│   ├── movies/         # Radarr + Plex
│   └── tv/             # Sonarr + Plex
├── config/             # Plex config
└── transmission/
    └── config/
```

Created by the Ansible nfs role. Manually:

```sh
sudo chown -R 1000:1000 /mnt/plex
sudo chmod -R 7555 /mnt/plex
cd /mnt/plex
mkdir -p {downloads/{incomplete,complete},media/{movies,tv},config,transmission/config}
```

The image is [lscr.io/linuxserver/plex](https://hub.docker.com/r/linuxserver/plex) and assumes uid/gid 1000 owns the media. Get a [claim token](https://www.plex.tv/claim/) — optional but easier — and put it in `secrets.enc.yaml` as `PLEX_CLAIM`. **It expires in 4 minutes**, so deploy promptly.

### Discord

Needs `DISCORD_TOKEN` in `secrets.enc.yaml` (from <https://discord.com/developers/applications>) and a GHCR pull secret — a fine-grained PAT with `read:packages`.

```sh
# force a redeploy after pushing a new image to the same tag
kubectl rollout restart deployment discord -n discord
```

## Post-install: Radarr/Sonarr download client

Registering Transmission in Radarr/Sonarr is manual: it is app-level config rather than cluster state, and it persists in each app's own database.

Do it once in each UI: **Settings → Download Clients → + → Transmission**

| Field | Value |
| --- | --- |
| Host | `transmission.transmission.svc.cluster.local` |
| Port | `9091` |
| Username / Password | from `transmission-secrets` |
| Use SSL | off |
| Add Paused | off |
| Remove Completed / Failed | on |

Then **Settings → Download Clients → Remote Path Mappings → +**

| Field | Value |
| --- | --- |
| Host | `transmission.transmission.svc.cluster.local` |
| Remote Path | `/downloads/complete` |
| Local Path | `/media/downloads/complete/` |

## API keys

Radarr and Sonarr keys are **pinned** in `secrets.enc.yaml` and injected as `RADARR__AUTH__APIKEY` / `SONARR__AUTH__APIKEY`. Both adopt them at startup, and Homepage reads the same values.

The key is declared rather than discovered, because Flux cannot read live cluster state to pass a generated key to Homepage.

Changing a key means updating it in `secrets.enc.yaml` — both the app and Homepage pick it up.

## NFS media

Radarr and Sonarr have `persistence.media.enabled: false`. The node has no NFS exports and `nfs_enabled` is false, so an unconditional mount would hang both pods in `ContainerCreating`.

To enable: attach the drive, set `nfs_enabled: true` in `ansible/group_vars/all.yml`, re-run the playbook, then flip `persistence.media` in both releases.

## Moving media onto the server

```sh
rsync -av --progress "Some Movie.mp4" {username}@{homelab_server_ip}:/mnt/plex/media/movies/
```
