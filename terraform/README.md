# Terraform

Deploys workloads onto the k3s cluster provisioned by Ansible. Run Ansible first.

## Deployment

```sh
cp terraform.tfvars.example terraform.tfvars  # fill in variables
terraform init
terraform apply
```

## Ingress: Traefik + MetalLB

MetalLB (Layer 2 mode) assigns real LAN IPs to LoadBalancer services — no NodePort tricks needed.

| Component     | IP / Range                         | tfvars key            |
| ------------- | ---------------------------------- | --------------------- |
| Node (minipc) | `192.168.0.210`                    | `node_ip`             |
| MetalLB pool  | `192.168.0.220 – 192.168.0.230`    | `metallb_pool`        |
| Traefik       | first IP in pool (`192.168.0.220`) | derived automatically |

Traefik is configured with:

- HTTP → HTTPS redirect on standard ports 80/443
- Fixed LoadBalancer IP `192.168.0.220` via MetalLB
- `local-ipallowlist` middleware (LAN-only access for Transmission)

All services use `ingressClassName: traefik` and self-signed TLS certs generated per-namespace by the `tls` provider.

> **Router prerequisite:** Set DHCP pool to `.2–.150`. Leave `.151–.253` for static use to avoid collisions with the MetalLB pool.

## Notes

### Accessing Services and Utilizing Self-Signed Certs

Update `/etc/hosts` (Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows) with the following:

```sh
# Traefik ingress services — point to MetalLB IP
192.168.0.220 kubecost.local transmission.local radarr.local sonarr.local homepage.local

# Plex — accessed directly via node NodePort, not through Traefik
192.168.0.210 plex.local
```

- Change `local` to whatever the `domain_root` variable is in your tfvars
- Plex is exposed via NodePort 32000 on the node directly: `http://192.168.0.210:32000/web/`

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

Access Plex by going to [http://{node-ip}:32000/web/](https://www.plex.tv/)

### Plex: Moving media

Moving a file from host computer to server:

```sh
cd /mnt/c/Users/James/Videos/Media
rsync -av --progress "Ghost In The Shell 1995.mp4" james@lab:/mnt/plex/movies/
```

## Modules

### Networking (MetalLB + Traefik)

Both are core cluster infrastructure and always deployed together via `modules/networking/`. Unlike other modules, networking has no feature flag — it is unconditionally applied on every `terraform apply`.

- **MetalLB** — Layer 2 LoadBalancer; IP pool `192.168.0.220–192.168.0.230`; announces IPs via ARP, no router config required.
- **Traefik** — Ingress controller; fixed IP `192.168.0.220` via MetalLB annotation; HTTP→HTTPS redirect; TLS termination with per-service self-signed secrets.
- `local-ipallowlist` Middleware restricts Transmission to LAN ranges.

### Discord-bot

```sh
# force k3s to pull the latest image and redeploy the pod
kubectl rollout restart deployment discord-bot
```

### Radarr

- Movie management for Plex using torrents or Usenet.
- Connects to Plex and Transmission.

### Sonarr

- TV show management, similar to Radarr.
- Connects to Plex and Transmission.

### Homepage

- Dashboard for managing all services.
- Displays app links, system stats, and service health.

### Transmission

- Torrent client used by Radarr/Sonarr.

### Kubecost

- Cost monitoring for Kubernetes.
- Track resource usage and costs across namespaces and workloads.
