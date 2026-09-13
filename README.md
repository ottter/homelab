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
