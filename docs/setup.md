# Setup

One-time steps to go from bare Ubuntu to a running cluster.

## 1. Network prerequisites

Router/network settings, done once.

- **Shrink the DHCP pool** to `.2 – .150` (or any range leaving `.151 – .253` free). MetalLB claims `192.168.0.220 – 192.168.0.230`; those must not be in the DHCP pool or you get address collisions.
- **Reserve `192.168.0.210`** for the node — a DHCP static lease by MAC, or assign it on the host.
- No router config is needed for MetalLB itself — it runs Layer 2 and announces via ARP.

### DNS

Ansible installs dnsmasq on the node. Point your PC's DNS (or the router's) at `192.168.0.210` and every `*.local` service resolves automatically.

- **Windows:** Settings → Network → DNS → `192.168.0.210`
- **Linux/macOS:** nameserver `192.168.0.210` in your network config
- **Router:** set it there to cover every LAN device at once

**Fallback** — if you can't change DNS, add to your hosts file (`C:\Windows\System32\drivers\etc\hosts` or `/etc/hosts`):

```text
192.168.0.220  homepage.local overseerr.local radarr.local sonarr.local transmission.local yam.local
192.168.0.221  plex.local
```

## 2. Tooling

| Tool | Purpose |
| --- | --- |
| `kubectl` | cluster access |
| `flux` | GitOps reconciliation |
| `sops` | encrypts secret values in git |
| `age` | encryption backend for sops |

```sh
sudo apt install age
curl -s https://fluxcd.io/install.sh | sudo bash        # flux
# sops: download the .deb from github.com/getsops/sops/releases
```

## 3. SSH key

```sh
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/{KEY_NAME}
ssh-copy-id -i ~/.ssh/{KEY_NAME}.pub {username}@{homelab_server_ip}
```

## 4. SOPS key

See [secrets.md](secrets.md). Short version:

```sh
age-keygen -o ~/.config/sops/age/keys.txt
```

Put the printed public key in `.sops.yaml`, and **back up `keys.txt` offline**.

## 5. Configure

| File | Holds |
| --- | --- |
| [`ansible/hosts.yml`](../ansible/hosts.yml) | server IP, username, SSH key path |
| [`ansible/group_vars/all.yml`](../ansible/group_vars/all.yml) | hostname, timezone, network, NFS |
| [`ansible/.env`](../ansible/.env.example) | `HOMELAB_PASSWORD`, `GITHUB_TOKEN` (gitignored) |
| [`clusters/mini/cluster-vars.yaml`](../clusters/mini/cluster-vars.yaml) | IPs, paths, domain, versions |

`cluster-vars.yaml` is shared: Flux substitutes from it and Ansible reads the same file, so the domain, IPs and paths are defined once. The only value that must be repeated is `ansible_host` in `hosts.yml` — keep it equal to `server_ip`.

The `GITHUB_TOKEN` needs `repo` **and** `workflow` scope — without `workflow`, pushes touching `.github/` are rejected.

## 6. Build

```sh
cd ansible/
cp .env.example .env          # fill in both values
set -a && . .env && set +a
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook_bootstrap.yml
```

Provisions OS hardening, k3s, NFS, dnsmasq, then bootstraps Flux and loads the age key. Idempotent — safe to re-run.

## 7. Trust the CA

Ansible writes the CA to `/etc/homelab-ca.crt` and fetches a copy to the repo root. Trust it once and every `*.local` service gets a valid cert.

```sh
scp {username}@{homelab_server_ip}:/etc/homelab-ca.crt ~/homelab-ca.crt
```

**Windows:**

```powershell
certutil -addstore -f "Root" homelab-ca.crt
```

**Linux:**

```sh
sudo cp homelab-ca.crt /usr/local/share/ca-certificates/homelab-ca.crt
sudo update-ca-certificates
```

**Firefox** uses its own store: Settings → Privacy & Security → Certificates → View Certificates → Authorities → Import.

## 8. Verify

```sh
export KUBECONFIG=ansible/kubeconfig
kubectl get nodes
flux get kustomizations        # all should be Ready
```

Verify hardening took effect:

```sh
ssh {username}@{homelab_server_ip} -i ~/.ssh/{KEY_NAME} 'sudo ufw status'
ssh {username}@{homelab_server_ip} -i ~/.ssh/{KEY_NAME} 'sudo fail2ban-client status sshd'
```
