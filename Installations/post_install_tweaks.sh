#!/bin/env bash
set -e 

read -p "Are you in root <su>?" -n 1 -r
echo #move to new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "perfect"
else 
	echo "Go in root via 'su', thanks! " && exit 1
fi

cd /root
echo "swapfile config"
dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
chmod 600 /swapfile
mkswap /swapfile
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /etc/fstab
swapon -a
free -m && sleep 1

echo "time sync" && sleep 1 
timedatectl set-timezone America/Montreal
systemctl enable systemd-timesyncd

echo "hostname"
hostnamectl set-hostname blade15
echo '127.0.0.1 localhost' | tee -a /etc/hosts
echo '127.0.1.1 blade15' | tee -a /etc/hosts
hostnamectl && sleep 4

echo "Launching 'install_on_arch' script now..."
su acerola

./~/.dotfiles/Installation/install_on_arch.sh
