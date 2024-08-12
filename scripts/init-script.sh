#!/bin/bash

# Define the static IP variable
STATIC_IP="192.168.1.100"
USERNAME=$(whoami)

sudo usermod -aG sudo $USERNAME

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y curl vim htop git unzip jq net-tools

# Set the static IP address
sudo cat <<EOF > /etc/network/interfaces.d/50-cloud-init.cfg
auto eth0
iface eth0 inet static
    address $STATIC_IP
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
EOF

# Backup the current SSH configuration file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Disable password authentication
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config

# Disable challenge-response authentication
sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#ChallengeResponseAuthentication no/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

# Disable PAM (Pluggable Authentication Module)
sudo sed -i 's/^#UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sudo sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sudo sed -i 's/^#UsePAM no/UsePAM no/' /etc/ssh/sshd_config

sudo systemctl restart ssh
sudo systemctl restart networking

# Install k3s (single-node)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -

# Set alias for kubectl to k and make it persistent
echo 'alias k="kubectl"' >> ~/.bashrc
source ~/.bashrc

# kubectl without sudo
sudo chmod 644 /etc/rancher/k3s/k3s.yaml