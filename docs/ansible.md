# Ansible

Provisions the machine. Everything above the OS is Flux's job — see [gitops.md](gitops.md).

Roles run in order: `common`, `hardening`, `k3s`, `networking`, `nfs`, `dnsmasq`, `flux`.

- System updates and base packages
- SSH key-only auth, UFW, fail2ban, kernel hardening
- k3s single-node cluster (PSA enforced, secrets encryption on)
- NFS storage (optional)
- dnsmasq for LAN-wide `*.local` resolution
- Flux bootstrap + the SOPS age key
- kubeconfig fetched to `ansible/kubeconfig`

All roles are idempotent — re-run at any time.

## Running

```sh
cd ansible/
set -a && . .env && set +a
ansible-playbook playbook_bootstrap.yml
```

## The flux role

Runs `delegate_to: localhost` — it uses the flux CLI in your WSL and `ansible/kubeconfig`. **Nothing is installed on the server** and `GITHUB_TOKEN` never leaves your machine.

It fails early with a clear message if the flux CLI, `GITHUB_TOKEN`, or the age key are missing, rather than halfway through a bootstrap.

It also exports the homelab CA to `/etc/homelab-ca.crt` and fetches a copy locally. Flux mints the CA but cannot write files to the server, and on a fresh build the secret does not exist until cert-manager has reconciled — so this step runs after the Kustomizations are ready.

## The networking role

Installs the Helm CLI and nothing else. MetalLB, Traefik, cert-manager and their config are owned by Flux in `infrastructure/` — two owners for the same resources causes drift.

Helm is not required — Flux's helm-controller runs in-cluster — so it is there only for inspecting releases by hand (`helm list`, `helm get values`). Set `networking_install_helm: false` to skip it.

To hand control back to Ansible, suspend Flux first:

```sh
flux suspend kustomization infra-controllers infra-configs
```

## k3s argument drift

The install task is guarded on binary existence, so a changed `k3s_extra_args` would otherwise be silently ignored and the repo would diverge from the server.

The role compares the desired args against `/etc/systemd/system/k3s.service` and reinstalls when they differ. Reinstalling is non-destructive: it replaces the binary and unit file but leaves `/var/lib/rancher/k3s` alone, so etcd and every workload survive. Same path a k3s version upgrade takes.

## NFS

When the external drive is attached:

1. Identify it: `lsblk`
2. Set `nfs_device` / `nfs_mount_point` in `group_vars/all.yml`
3. Set `nfs_enabled: true`
4. Re-run the playbook

Then enable `persistence.media` in the Radarr/Sonarr releases — see [apps.md](apps.md).

## WSL caveats

`/mnt/c` is world-writable, so Ansible **ignores `ansible.cfg`**. Pass it explicitly if you need its settings:

```sh
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook -i hosts.yml playbook_bootstrap.yml
```

## Variable reference

Settings shared with the cluster — IPs, domain, timezone, storage paths — live in
[`clusters/mini/cluster-vars.yaml`](../clusters/mini/cluster-vars.yaml) and are mapped onto
Ansible variable names in the playbook — chart and image versions included.
Only Ansible-specific tuneables remain in [`group_vars/all.yml`](../ansible/group_vars/all.yml),
including `k3s_version`, since only Ansible installs k3s.

The node IP appears twice on purpose: `ansible_host` in `hosts.yml` cannot read cluster-vars,
because the inventory is parsed before `vars_files` loads. Keep the two equal.

### From cluster-vars

| Key | Default | Description |
| --- | --- | --- |
| `server_ip` | `192.168.0.210` | k3s node; also the Ansible target |
| `lan_subnet` | `192.168.0.0/24` | Allowed for SSH / k3s API / DNS |
| `domain_root` | `local` | dnsmasq domain and ingress hostnames |
| `timezone` | `America/New_York` | System and container timezone |
| `traefik_lb_ip` | `192.168.0.220` | Traefik IP — first in the MetalLB pool |
| `plex_lb_ip` | `192.168.0.221` | Plex IP — within the pool |
| `metallb_pool` | `192.168.0.220-192.168.0.230` | LoadBalancer range — must not overlap DHCP |
| `nfs_mount_point` | `/mnt/plex` | Media root |

### Ansible-only

| Variable | Default | Description |
| --- | --- | --- |
| `hostname` | `minipc` | Server hostname |
| `k3s_version` | `v1.35.3+k3s1` | k3s release; changing it reinstalls in place |
| `k3s_force_reinstall` | `false` | Force a k3s reinstall |
| `hardening_ssh_port` | `22` | SSH port |
| `hardening_ssh_password_auth` | `no` | Set `yes` temporarily if the key is not on the server yet |
| `hardening_fail2ban_maxretry` | `5` | Failed attempts before ban |
| `hardening_fail2ban_bantime` | `3600` | Ban duration (seconds) |
| `nfs_enabled` | `false` | Enable when the external drive is attached |
| `nfs_device` | `/dev/sdb1` | Drive device path |
| `nfs_fs_type` | `xfs` | Filesystem type |
| `nfs_owner_uid` | `1000` | UID owning the NFS directories |
| `networking_install_helm` | `true` | Install the Helm CLI on the server |
