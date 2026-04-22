# Terraform

Deploys workloads onto the k3s cluster provisioned by Ansible. Run Ansible first.

## Deployment

```sh
# terraform.tfvars is the tracked template — copy it and fill in secrets
cp terraform.tfvars homelab.tfvars
terraform init
terraform apply -var-file=homelab.tfvars
```

## Ingress: Traefik + MetalLB

MetalLB and Traefik are provisioned by **Ansible** (`roles/networking`), not by Terraform. Terraform only needs the resulting IPs to annotate services and build URLs.

| Component | IP              | tfvars key      | Ansible (`group_vars/all.yml`) |
| --------- | --------------- | --------------- | ------------------------------ |
| Node      | `192.168.0.210` | `node_ip`       | `server_lan_ip`                |
| Traefik   | `192.168.0.220` | `traefik_lb_ip` | `traefik_lb_ip`                |
| Plex      | `192.168.0.221` | `plex_lb_ip`    | `plex_lb_ip`                   |

`traefik_lb_ip` and `plex_lb_ip` must match between `terraform/homelab.tfvars` and `ansible/group_vars/all.yml`. Ansible also sets `metallb_pool` — `traefik_lb_ip` must be its first IP.

Traefik is configured with:

- HTTP -> HTTPS redirect on standard ports 80/443
- Fixed LoadBalancer IP via MetalLB annotation
- `local-ipallowlist` Middleware (LAN-only access for Transmission)

All services use `ingressClassName: traefik` and self-signed TLS certs generated per-namespace.

> **Router prerequisite:** Set DHCP pool to `.2-.150`. Leave `.151-.253` for static use to avoid collisions with the MetalLB pool.

## Notes

### Accessing Services

Ansible deploys dnsmasq on the node, which resolves all `*.{domain_root}` queries automatically. Set your DNS server to the node IP once — no `/etc/hosts` maintenance needed.

**Windows:** Settings -> Network -> DNS -> set to `192.168.0.210`
**Linux/Mac:** Set nameserver `192.168.0.210` in your network config or `/etc/resolv.conf`
**Router:** Set the DNS server to `192.168.0.210` to apply to all LAN devices

> **Domain consistency:** `domain_root` in `terraform/homelab.tfvars` must match `domain_suffix` in `ansible/group_vars/all.yml`. Both default to `local`.

**Fallback — `/etc/hosts`:** If you prefer not to change DNS, run:

```sh
terraform output hosts_file
```

Paste the output into `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows).

> Plex gets its own MetalLB IP (`plex_lb_ip`, default `192.168.0.221`) and is accessed at `http://plex.local:32400/web/`. It bypasses Traefik entirely — Plex handles its own TLS and does not play well with reverse proxies.

### Plex: Preconfiguration

This is utilizing the docker image [lscr.io/linuxserver/plex:latest](https://hub.docker.com/r/linuxserver/plex) and
assumes that the 1000:1000 account is the one managing plex. Change as needed. **Preconfiguration can be skipped if the
cluster was deployed via the Ansible script!**

Getting the [Plex Claim token](https://www.plex.tv/claim/) is optional but preferred for easier setup. It lasts for 4
minutes so make it quick.

```sh
/mnt/plex/
├── downloads/         # Transmission temp storage
│   ├── incomplete/
│   └── complete/
├── media/
│   ├── movies/        # Radarr
│   └── tv/            # Sonarr
├── config/
```

```sh
# This is completed by Ansible: homelab/task/nfs.yml
sudo chown -R 1000:1000 /mnt/plex
sudo chmod -R 7555 /mnt/plex
cd /mnt/plex
mkdir -p {downloads/{incomplete,complete},media/{movies,tv},config}
```

Access Plex by going to `http://plex.{domain_root}:32400/web/` (e.g. `http://plex.local:32400/web/`)

### Plex: Moving media

Moving a file from host computer to server:

```sh
cd /mnt/c/Users/James/Videos/Media
rsync -av --progress "Ghost In The Shell 1995.mp4" james@lab:/mnt/plex/movies/
```

## Modules

### Discord-bot

```sh
# force k3s to pull the latest image and redeploy the pod
kubectl rollout restart deployment discord-bot
```

### Radarr

Accessible at `https://radarr.{domain_root}`

- Movie management for Plex using torrents or Usenet.
- Connects to Plex and Transmission.

### Sonarr

Accessible at `https://sonarr.{domain_root}`

- TV show management, similar to Radarr.
- Connects to Plex and Transmission.

### Homepage

Accessible at `https://homepage.{domain_root}`

- Dashboard for managing all services.
- Displays app links, system stats, and service health.

### Overseerr

Accessible at `https://overseerr.{domain_root}`

- A request management and media discovery tool built to work with your existing Plex ecosystem.

### Transmission

Accessible at `https://transmission.{domain_root}`

- Torrent client used by Radarr/Sonarr.

### Yamtrack

Accessible at `https://yam.{domain_root}`

- Self-hosted media tracker for movies, TV, anime, games, books, and more.
- User data (watchlist, ratings) is stored in SQLite at the hostPath `/mnt/yamtrack/db`.
