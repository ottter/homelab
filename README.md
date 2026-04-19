# Single node k3s homelab

Single-node Ubuntu homelab provisioned with Ansible. Runs a k3s Kubernetes cluster with Traefik ingress and security hardening.

See [`ansible/README.md`](ansible/README.md) and [`terraform/README.md`](terraform/README.md) for full details.

## Structure

```text
ansible/    — server provisioning (OS hardening, k3s, MetalLB, Traefik, NFS, dnsmasq)
terraform/  — cluster workloads (Plex, Radarr, Sonarr, Transmission, Homepage, etc.)
```

## Network prerequisites

These are one-time router/network settings required before deploying.

- **Shrink your router's DHCP pool** to `.2 – .150` (or any range that leaves `.151 – .253` free). MetalLB uses `192.168.0.220 – 192.168.0.230` for LoadBalancer IPs — those addresses must not be in the DHCP pool or collisions will occur.
- **Reserve `192.168.0.210`** for the homelab node (set a DHCP static lease by MAC address, or assign it manually on the host).
- No router config is required for MetalLB — it operates in Layer 2 mode and announces IPs via ARP.
- **DNS:** Ansible installs dnsmasq on the node. Point your PC's DNS (or router DNS) at `192.168.0.210` — all `*.local` services resolve automatically. No `/etc/hosts` edits needed.
- **IP + domain consistency:** Three values must stay in sync across Ansible and Terraform:
  - `traefik_lb_ip` — `ansible/group_vars/all.yml` and `terraform/homelab.tfvars`
  - `plex_lb_ip` — `ansible/group_vars/all.yml` and `terraform/homelab.tfvars`
  - `domain_suffix` (Ansible) / `domain_root` (Terraform) — both default to `local`

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
cp terraform.tfvars homelab.tfvars  # terraform.tfvars is the committed template — copy and fill in secrets
terraform init
terraform apply -var-file=homelab.tfvars
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
