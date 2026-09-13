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

It also exports the homelab CA to `/etc/homelab-ca.crt` and fetches a copy locally. That lives here rather than in the networking role because Flux mints the CA but cannot write files to the server — and on a fresh build the secret does not exist until Flux has reconciled cert-manager.

## The networking role

Now installs the Helm CLI and nothing else. MetalLB, Traefik, cert-manager and their config moved to `infrastructure/`, because two owners for the same resources causes drift.

Helm is not required — Flux's helm-controller runs in-cluster — so it is there only for inspecting releases by hand (`helm list`, `helm get values`). Set `networking_install_helm: false` to skip it.

To hand control back to Ansible, suspend Flux first and restore the tasks from git history:

```sh
flux suspend kustomization infra-controllers infra-configs
```

## k3s argument drift

The install task is guarded on binary existence, so changing `k3s_extra_args` on an existing install used to be silently ignored — the repo and server would diverge.

The role now compares the desired args against `/etc/systemd/system/k3s.service` and reinstalls when they differ. Reinstalling is non-destructive: it replaces the binary and unit file but leaves `/var/lib/rancher/k3s` alone, so etcd and every workload survive. Same path a k3s version upgrade takes.

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

Tuneables live in [`group_vars/all.yml`](../ansible/group_vars/all.yml); versions live in [`versions.yaml`](../versions.yaml).

| Variable | Default | Description |
| --- | --- | --- |
| `server_lan_ip` | `192.168.0.210` | Server LAN IP |
| `lan_subnet` | `192.168.0.0/24` | Subnet allowed for SSH/k3s/DNS |
| `hostname` | `minipc` | Server hostname |
| `timezone` | `America/New_York` | System timezone |
| `domain_suffix` | `local` | dnsmasq domain — **must match `domain_root` in cluster-vars** |
| `networking_traefik_lb_ip` | `192.168.0.220` | Traefik IP, for dnsmasq — keep in sync with cluster-vars |
| `plex_lb_ip` | `192.168.0.221` | Plex IP, for dnsmasq — keep in sync with cluster-vars |
| `k3s_force_reinstall` | `false` | Force a k3s reinstall |
| `hardening_ssh_port` | `22` | SSH port |
| `hardening_ssh_password_auth` | `no` | Set `yes` temporarily if the key is not on the server yet |
| `hardening_fail2ban_maxretry` | `5` | Failed attempts before ban |
| `hardening_fail2ban_bantime` | `3600` | Ban duration (seconds) |
| `nfs_enabled` | `false` | Enable when the external drive is attached |
| `nfs_device` | `/dev/sdb1` | Drive device path |
| `nfs_mount_point` | `/mnt/plex` | Mount point |
| `nfs_fs_type` | `xfs` | Filesystem type |
| `nfs_owner_uid` | `1000` | UID owning the NFS directories |
| `networking_install_helm` | `true` | Install the Helm CLI on the server |
