# Single node k3s homelab

Single-node Ubuntu homelab. Ansible provisions the machine; Flux runs the cluster from this repo.

```text
ansible/          server provisioning (hardening, k3s, NFS, dnsmasq, Flux bootstrap)
clusters/         Flux entrypoint per cluster
infrastructure/   cluster addons (MetalLB, cert-manager, Traefik)
apps/             workloads
docs/             documentation
```

## Deploy

One command builds the cluster. After that, `git push` is the deploy.

```sh
cd ansible/
set -a && . .env && set +a
ansible-playbook playbook_bootstrap.yml
```

```sh
git push        # Flux reconciles the repo onto the cluster
```

## Configuration

Two files hold everything you would normally want to change. Both tools read
them, so a value is defined once.

| File | Holds | Read by |
| --- | --- | --- |
| [`clusters/mini/cluster-vars.yaml`](clusters/mini/cluster-vars.yaml) | IPs, domain, timezone, paths, **versions** | Flux (substitution) + Ansible (`vars_files`) |
| [`ansible/group_vars/all.yml`](ansible/group_vars/all.yml) | SSH hardening, fail2ban, NFS device, k3s version | Ansible only |

Secrets are separate and encrypted — see [docs/secrets.md](docs/secrets.md).

### Changing Settings

**An IP, the domain, the timezone, a storage path** → edit `cluster-vars.yaml`.
Flux substitutes `${domain_root}` and friends into manifests at apply time, and
the Ansible playbook maps the same keys onto its own variable names.

```sh
ansible-playbook playbook_bootstrap.yml   # if it affects the server (dnsmasq, firewall)
git push                                  # if it affects the cluster
```

An undefined `${var}` substitutes to an **empty string with no error**, so check
the key exists before pushing.

> The node IP is the one value defined twice: `ansible_host` in
> [`ansible/hosts.yml`](ansible/hosts.yml) is read before `vars_files` loads, so
> it cannot reference `cluster-vars`. Keep it equal to `server_ip`.

**A chart or image version** → edit `cluster-vars.yaml`. The manifests carry
`${radarr_version}` and friends, so the version is written once.

```yaml
# clusters/mini/cluster-vars.yaml
radarr_version: "27.13.1"     # apps/base/radarr/release.yaml
plex_image_tag: "1.43.4"      # apps/base/plex/deployment.yaml
```

```sh
git push
```

**The k3s version** → edit `ansible/group_vars/all.yml`, then re-run the
playbook. Only Ansible installs k3s, so it does not belong in the cluster
ConfigMap. Changing it reinstalls k3s in place, preserving all workloads.

## Docs

| | |
| --- | --- |
| [Setup](docs/setup.md) | First-time build: network, tooling, keys, CA trust |
| [GitOps](docs/gitops.md) | How Flux works here, adding apps, versions |
| [Secrets](docs/secrets.md) | SOPS + age, editing secrets, key rotation |
| [Apps](docs/apps.md) | What runs, URLs, per-app setup |
| [Ansible](docs/ansible.md) | Roles, variables, k3s drift |
| [Troubleshooting](docs/troubleshooting.md) | When something breaks |

## Services

`https://homepage.local` is the dashboard. Full list in [docs/apps.md](docs/apps.md).
