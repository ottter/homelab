# homelab

## Init

Before running `init-script.sh` on the server, run this on host

```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
ssh-copy-id username@your_homelab_server_ip

scp init-script.sh username@192.168.1.100:/home/username/

# If doing manually (instead of ssh-copy-id), do on server
mkdir -p ~/.ssh
echo "your_copied_public_key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```
