# Single node k3s homelab

Single-node Ubuntu homelab provisioned with Ansible. Runs a k3s Kubernetes cluster with Traefik ingress and security hardening.

See [`ansible/README.md`](ansible/README.md) and [`terraform/README.md`](terraform/README.md) for full details.

## Structure

```text
ansible/         — server provisioning (OS hardening, k3s, MetalLB, Traefik, NFS, dnsmasq, Flux bootstrap)
clusters/        — Flux entrypoint per cluster
infrastructure/  — cluster addons managed by Flux
apps/            — workloads (Plex, Radarr, Sonarr, Transmission, Homepage, etc.)
terraform/       — legacy, being migrated to Flux
```

## Tooling prerequisites

Run from WSL (Ubuntu). `age` 1.0.0 from apt is fine — the file format is stable.

| Tool | Purpose |
| --- | --- |
| `kubectl` | cluster access |
| `flux` | GitOps reconciliation |
| `sops` | encrypts secret values in git |
| `age` | encryption backend for sops |

```sh
sudo apt install age
# flux: curl -s https://fluxcd.io/install.sh | sudo bash
# sops: download .deb from github.com/getsops/sops/releases
```

### SOPS key setup (once)

```sh
age-keygen -o ~/.config/sops/age/keys.txt   # public key goes in .sops.yaml
```

**Back up `keys.txt` offline.** Without it every `*.enc.yaml` in this repo is unrecoverable.

Edit secrets with `sops path/to/file.enc.yaml` — decrypts to your editor, re-encrypts on save.

## Network prerequisites

These are one-time router/network settings required before deploying.

- **Shrink your router's DHCP pool** to `.2 – .150` (or any range that leaves `.151 – .253` free). MetalLB uses `192.168.0.220 – 192.168.0.230` for LoadBalancer IPs — those addresses must not be in the DHCP pool or collisions will occur.
- **Reserve `192.168.0.210`** for the homelab node (set a DHCP static lease by MAC address, or assign it manually on the host).
- No router config is required for MetalLB — it operates in Layer 2 mode and announces IPs via ARP.
- **DNS:** Ansible installs dnsmasq on the node. Point your PC's DNS (or router DNS) at `192.168.0.210` — all `*.local` services resolve automatically. If you can't change DNS settings, add entries manually to your hosts file instead:
  - **Windows:** `C:\Windows\System32\drivers\etc\hosts`
  - **Linux/macOS:** `/etc/hosts`

  ```text
  192.168.0.220  homepage.local traefik.local sonarr.local radarr.local transmission.local
  192.168.0.221  plex.local
  ```

- **IP + domain consistency:** Three values must stay in sync across Ansible and Terraform:
  - `networking_traefik_lb_ip` — `ansible/group_vars/all.yml` and `terraform/homelab.tfvars`
  - `plex_lb_ip` — `ansible/group_vars/all.yml` and `terraform/homelab.tfvars`
  - `domain_suffix` (Ansible) / `domain_root` (Terraform) — both default to `local`

## Deployment

One command builds the cluster. After that, deploying apps is `git push` — Flux reconciles the repo onto the cluster automatically.

### Build the cluster

```sh
# Generate SSH key (once)
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/{KEY_NAME}
ssh-copy-id -i ~/.ssh/{KEY_NAME}.pub {username}@{homelab_server_ip}

# Configure and run
cd ansible/
cp .env.example .env  # fill out the variables with correct information
set -a && . .env && set +a
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook_bootstrap.yml
```

Provisions the OS, k3s, MetalLB/Traefik/cert-manager, NFS, dnsmasq, then bootstraps Flux and loads the age key for secret decryption. Idempotent — safe to re-run.

Changing `k3s_extra_args` triggers a k3s reinstall to converge the running service. This preserves `/var/lib/rancher/k3s` — etcd and all workloads survive.

### Deploy apps

```sh
git push
```

Flux polls the repo and applies `clusters/mini`. To force an immediate sync:

```sh
flux reconcile kustomization flux-system --with-source
```

## Trusting the homelab CA

Ansible writes the CA cert to `/etc/homelab-ca.crt` on the server. Copy it to your PC and trust it once — all `*.local` services will then show a valid certificate with no browser warnings.

```sh
scp {username}@{homelab_server_ip}:/etc/homelab-ca.crt ~/homelab-ca.crt
```

**Windows** — import into the system trust store:

```powershell
certutil -addstore -f "Root" homelab-ca.crt
```

**Linux** — copy to trusted CAs and update:

```sh
sudo cp homelab-ca.crt /usr/local/share/ca-certificates/homelab-ca.crt
sudo update-ca-certificates
```

**Firefox** — Firefox uses its own trust store. Go to Settings → Privacy & Security → Certificates → View Certificates → Authorities → Import, and select `homelab-ca.crt`.

## Troubleshooting

### Namespace stuck in Terminating

```sh
NS=`kubectl get ns | grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
```

### Force k3s image pull and redeploy

```sh
kubectl rollout restart deployment <name>
```

### Copy files to server

```sh
rsync -av --progress /path/to/file {username}@{homelab_server_ip}:/mnt/plex/media/movies/
```
