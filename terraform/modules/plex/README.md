# Plex

Deploys Plex Media Server using the [linuxserver/plex](https://hub.docker.com/r/linuxserver/plex) image. Exposed directly via a dedicated MetalLB LoadBalancer IP — bypasses Traefik entirely.

## Access

```txt
http://plex.{domain_root}:32400/web/
```

e.g. `http://plex.local:32400/web/`

Plex does not go through Traefik and has no TLS certificate. Use Plex's built-in remote access for external connections.

## Variables

| Variable | Description | Default |
| --- | --- | --- |
| `plex_token` | Claim token from <https://plex.tv/claim> — used once on first setup, expires in 4 minutes | required |
| `plex_lb_ip` | MetalLB LoadBalancer IP for the Plex service | required |
| `plex_path_config` | hostPath on the node for Plex config and database | `/mnt/plex/config` |
| `plex_path_tv` | hostPath on the node for TV series | `/mnt/plex/tv` |
| `plex_path_movies` | hostPath on the node for movies | `/mnt/plex/movies` |

## Host Directory Setup

The three hostPath directories must exist on the node before deploying, owned by UID/GID 1000:

```sh
ssh james@lab sudo mkdir -p /mnt/plex/{config,tv,movies}
sudo chown -R 1000:1000 /mnt/plex
```

This is handled automatically by Ansible (`tasks/nfs.yml`) if NFS is configured.

## Notes

- `PUID`/`PGID` are hardcoded to `1000` — the host directories must be owned by this user
- `PLEX_CLAIM` is only used on first boot to link the server to your Plex account; it is ignored on subsequent starts
- The liveness probe checks `/health` on port 32400 starting 60 seconds after pod start
- To force a pod restart (e.g. after a config change): `kubectl rollout restart deployment plex -n plex`
