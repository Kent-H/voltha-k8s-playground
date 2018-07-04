#!/bin/bash

set -e

echo "Installing Ansible..."
apt-get update -y
apt-get install -y software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update -y
apt-get install -y ansible apt-transport-https

echo "Installing Python..."
apt-get install -y python-minimal
apt-get install -y python-netaddr

echo 'Disable swaps'
swapoff -a
sed -i -e 's/^\/.* swap .*/#&/' /etc/fstab

echo 'Copying ansible-vm public SSH Keys to the VM'
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod -R 600 /home/vagrant/.ssh/authorized_keys

echo 'Host *' >> /home/vagrant/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
