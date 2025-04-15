# Single node k3s homelab

## Prereq notes

- Ansible creates an NFS device out of `/dev/sdb1` (default variable). This should be manually done if not using Ansible. Including the directory structure that Plex requires

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

### Discord-bot

```sh
# force k3s to pull the latest image and redeploy the pod
kubectl rollout restart deployment discord-bot
```

### Plex: Preconfiguration

This is utilizing the docker image [lscr.io/linuxserver/plex:latest](https://hub.docker.com/r/linuxserver/plex) and assumes that the 1000:1000 account is the one managing plex. change as needed

Getting the [Plex Claim token](https://www.plex.tv/claim/) is optional but preferred for easier setup. It lasts for 4 minutes so make it quick.

```sh
/mnt/plex/
├── downloads/         # where Transmission puts incomplete and complete downloads
│   ├── incomplete/
│   └── complete/
├── media/
│   ├── movies/        # uRadarr
│   └── tv/            # Sonarr
```

```sh
# This is completed by Ansible: homelab/task/nfs.yml
sudo chown -R 1000:1000 /mnt/plex
sudo chmod -R 7555 /mnt/plex
cd /mnt/plex
mkdir config movies tv
```

Access Plex by going to [http://{node-ip}:32000/web/](https://www.plex.tv/)

### Plex: Moving media

Moving a file from host computer to server:

```sh
cd /mnt/c/Users/James/Videos/Media
rsync -av --progress "Ghost In The Shell 1995.mp4" james@lab:/mnt/plex/movies/
```

### Enable kubectl autocomplete

```sh
apt-get install bash-completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```
