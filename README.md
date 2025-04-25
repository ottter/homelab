# Single node k3s homelab

## Prereq notes

- Ansible creates an NFS device out of `/dev/sdb1` (default variable). This should be manually done if not using
Ansible. Including the directory structure that Plex requires

## Init

```sh
# on the server
sudo apt install openssh-server

# on host machine
ssh-keygen -t rsa -b 4096 -C "email@example.com"
ssh-copy-id [username]@[homelab_server_ip]

# test ansible connection from host to server
ansible remote -m ping -i hosts
```

```sh
# Set the root password for the homelab server as an environment variable on host
export HOMELAB_PASSWORD="password"
```

```sh
# Run the playbook
cd ansible
ansible-playbook playbook_bootstrap.yml -i hosts --ask-become-pass
# password will prompt for localhost password

cd terraform
terraform apply -var-file=homelab.tfvars
```

### Accessing Services and Utilizing Self-Signed Certs

Update `/etc/hosts` (Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows) with the following:

```sh
192.168.0.144 kubecost.local plex.local transmission.local radarr.local sonarr.local homepage.local
```

- Change the IP address to the static IP of the local server. This should match `node_ip` variable in your tfvars
- Change `local` to whatever the `domain_root` variable is in your tfvars

This will allow you to go to `https://plex.local`, for example, and access Plex.

### Plex: Preconfiguration

This is utilizing the docker image [lscr.io/linuxserver/plex:latest](https://hub.docker.com/r/linuxserver/plex) and
assumes that the 1000:1000 account is the one managing plex. Change as needed. **Preconfiguration can be skipped if the
cluster was deployed via the Ansible script!**

Getting the [Plex Claim token](https://www.plex.tv/claim/) is optional but preferred for easier setup. It lasts for 4
minutes so make it quick.

```sh
/mnt/plex/
├── downloads/         # Transmission temp storage
│   ├── incomplete/
│   └── complete/
├── media/
│   ├── movies/        # Radarr
│   └── tv/            # Sonarr
├── config/
```

```sh
# This is completed by Ansible: homelab/task/nfs.yml
sudo chown -R 1000:1000 /mnt/plex
sudo chmod -R 7555 /mnt/plex
cd /mnt/plex
mkdir -p {downloads/{incomplete,complete},media/{movies,tv},config}
```

Access Plex by going to [http://{node-ip}:32000/web/](https://www.plex.tv/)

### Plex: Moving media

Moving a file from host computer to server:

```sh
cd /mnt/c/Users/James/Videos/Media
rsync -av --progress "Ghost In The Shell 1995.mp4" james@lab:/mnt/plex/movies/
```

## Modules

### Discord-bot

```sh
# force k3s to pull the latest image and redeploy the pod
kubectl rollout restart deployment discord-bot
```

### Radarr

- Movie management for Plex using torrents or Usenet.
- Connects to Plex and Transmission.

### Sonarr

- TV show management, similar to Radarr.
- Connects to Plex and Transmission.

### Homepage

- Dashboard for managing all services.
- Displays app links, system stats, and service health.

### Transmission

- Torrent client used by Radarr/Sonarr.

### Kubecost

- Cost monitoring for Kubernetes.
- Track resource usage and costs across namespaces and workloads.

## Misc helpful tips & Troubleshooting

### Enable kubectl autocomplete

```sh
apt-get install bash-completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

Namespace stuck in `Terminating`:

```sh
NS=`kubectl get ns |grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"  | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
```
