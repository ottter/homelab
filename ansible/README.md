# Homelab Ansible

Provisions a single-node Ubuntu homelab with:

- System updates and base packages
- SSH key-only auth, UFW firewall, fail2ban, kernel hardening
- k3s single-node Kubernetes cluster
- kubeconfig fetched locally so you can use `kubectl` from this machine

All roles are idempotent — re-run `playbook_bootstrap.yml` at any time.

## Prerequisites (manual — do once)

1. **Ubuntu installed** on the server with a sudo user
2. **DHCP reservation** — ensure the server IP is reserved for its MAC in your router
3. **SSH key on server** — your Ansible SSH key must already be in `authorized_keys`

   ```sh
   ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/{KEY_NAME}
   ssh-copy-id -i ~/.ssh/{KEY_NAME}.pub {username}@{homelab_server_ip}
   ```

4. **Ansible collections** installed:

   ```sh
   cd ansible/
   ansible-galaxy collection install -r requirements.yml
   ```

## Configuration

Edit these two files before running:

- **[`hosts.yml`](hosts.yml)** — server IP, username, SSH key path
- **[`group_vars/all.yml`](group_vars/all.yml)** — hostname, timezone, k3s version, NFS settings

## Environment setup (before every run)

`.env` holds only the sudo password (gitignored). Copy and fill it in once:

```sh
cp .env.example .env
# edit .env — set HOMELAB_PASSWORD
set -a && . .env && set +a
```

## Run

```sh
ansible-playbook playbook_bootstrap.yml
```

What it does:

- Updates all packages
- Installs base tools, ufw, fail2ban
- Copies SSH public key to `authorized_keys` (idempotent — safe on fresh installs)
- Configures UFW: deny all incoming except SSH (port 22) and k3s API (port 6443) from LAN only
- Hardens SSH: key-only auth, no root login, restricted to configured user
- Applies kernel sysctl hardening
- Configures fail2ban for SSH (5 retries, 1h ban)
- Installs k3s (skips if already installed, unless `k3s_force_reinstall: true`)
- Copies kubeconfig to `~/.kube/config` on the server
- Fetches kubeconfig to `ansible/kubeconfig` with server address rewritten to LAN IP
- Sets up NFS storage (skipped unless `nfs_enabled: true` in `group_vars/all.yml`)
- Installs and configures dnsmasq: resolves `*.{domain_suffix}` to Traefik (`traefik_lb_ip`) and `plex.{domain_suffix}` to its own MetalLB IP (`plex_lb_ip`)

**Test from this machine:**

```sh
KUBECONFIG=ansible/kubeconfig kubectl get nodes
```

**Test from the server:**

```sh
ssh {username}@{homelab_server_ip} -i ~/.ssh/{KEY_NAME}
kubectl get nodes
```

## NFS storage (when external drive is attached)

1. Attach the drive and identify it on the server: `lsblk`
2. Update `nfs_device` and `nfs_mount_point` in `group_vars/all.yml` if needed
3. Set `nfs_enabled: true` in `group_vars/all.yml`
4. Re-run: `ansible-playbook playbook_bootstrap.yml`

## Verify hardening

```sh
# SSH: should connect with key, no password prompt
ssh {username}@{homelab_server_ip} -i ~/.ssh/{KEY_NAME}

# UFW status
ssh {username}@{homelab_server_ip} -i ~/.ssh/{KEY_NAME} 'sudo ufw status'

# fail2ban status
ssh {username}@{homelab_server_ip} -i ~/.ssh/{KEY_NAME} 'sudo fail2ban-client status sshd'
```

## Variable reference

All tuneable variables are in [`group_vars/all.yml`](group_vars/all.yml):

| Variable | Default | Description |
| --- | --- | --- |
| `server_lan_ip` | — | Server LAN IP (set in hosts.yml) |
| `lan_subnet` | `192.168.0.0/24` | Subnet allowed for SSH/k3s/DNS |
| `domain_suffix` | `local` | Domain suffix for dnsmasq — **must match `domain_root` in `terraform/homelab.tfvars`** |
| `traefik_lb_ip` | `192.168.0.220` | Traefik LoadBalancer IP — **must match first IP of `metallb_pool` in `terraform/homelab.tfvars`** |
| `plex_lb_ip` | `192.168.0.221` | Plex LoadBalancer IP — **must match `plex_lb_ip` in `terraform/homelab.tfvars`** |
| `k3s_version` | `v1.35.3+k3s1` | k3s version to install |
| `k3s_force_reinstall` | `false` | Set true to reinstall k3s |
| `ssh_password_auth` | `no` | Set to `yes` temporarily if key not yet on server |
| `nfs_enabled` | `false` | Set to `true` when external drive is attached |
| `nfs_device` | `/dev/sdb1` | External drive device path |
| `nfs_mount_point` | `/mnt/plex` | NFS mount point |
