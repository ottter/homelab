# Single node k3s homelab

Single-node Ubuntu homelab provisioned with Ansible. Runs a k3s Kubernetes cluster with security hardening.

See [`ansible/README.md`](ansible/README.md) for full setup and run instructions.

## Structure

```text
ansible/    — server provisioning (OS hardening, k3s, NFS)
terraform/  — infrastructure as code
```

## Quick start

```sh
# Generate SSH key for Ansible (once)
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/{KEY_NAME}
ssh-copy-id -i ~/.ssh/{KEY_NAME}.pub {username}@{homelab_server_ip}

# Configure and run
cd ansible/
cp .env.example .env  # fill in own information
set -a && . .env && set +a
ansible-galaxy collection install -r requirements.yml

# Run playbook (rerunable)
ansible-playbook playbook_bootstrap.yml
```

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
