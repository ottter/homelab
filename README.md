# Single node k3s homelab

Single-node Ubuntu homelab provisioned with Ansible. Runs a k3s Kubernetes cluster with Traefik ingress and security hardening.

See [`ansible/README.md`](ansible/README.md) and [`terraform/README.md`](terraform/README.md) for full details.

## Structure

```text
ansible/    — server provisioning (OS hardening, k3s, NFS)
terraform/  — cluster workloads and ingress (Traefik, Plex, Radarr, Sonarr, etc.)
```

## Deployment order

Ansible must run first to provision the server and bring up k3s, then Terraform deploys workloads onto the cluster.

### 1. Provision with Ansible

```sh
# Generate SSH key (once)
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/{KEY_NAME}
ssh-copy-id -i ~/.ssh/{KEY_NAME}.pub {username}@{homelab_server_ip}

# Configure and run
cd ansible/
cp .env.example .env  # fill in own information
set -a && . .env && set +a
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook_bootstrap.yml
```

### 2. Deploy with Terraform

```sh
cd terraform/
cp terraform.tfvars.example terraform.tfvars  # fill in own information
terraform init
terraform apply
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
