# Single node k3s homelab

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

Set the root password for the homelab server as an environment variable `HOMELAB_PASSWORD`

```sh
export HOMELAB_PASSWORD="password'
```

Run the playbook

```sh
ansible-playbook playbook_bootstrap.yml -i hosts --ask-become-pass
# password will prompt for localhost password
```
