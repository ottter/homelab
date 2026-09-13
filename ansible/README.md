# Ansible

Provisions the machine: OS hardening, k3s, NFS, dnsmasq, and the Flux bootstrap.

```sh
cd ansible/
set -a && . .env && set +a
ansible-playbook playbook_bootstrap.yml
```

Idempotent — safe to re-run.

See [docs/ansible.md](../docs/ansible.md) for roles, variables, and the k3s drift check, or [docs/setup.md](../docs/setup.md) for a first-time build.
