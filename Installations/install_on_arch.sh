#!/bin/env bash

set -e  #stop stops the excecution of script if command or pipeline has an error.
cd ~/
echo "Welcome Acerola!" && sleep 2


#Default var 
HELPER="aura"
FILE="iDoNotExist"

# full system update, just in case ;)
echo "Doing a system update... Stuff may break if not the lastest version..."
sudo pacman --noconfirm -Syu  #--noconfirm will bypass "are you sure?"

# To be able to makepkg of AUR
sudo pacman --noconfirm --needed base-devel

# AUR installation
echo "AUR installation, $HELPER is being installed"
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin && makepkg
sudo pacman -U --noconfirm --needed aura-bin-3.2.6-1-x86_64.pkg.tar.zst

##### When this fails -> uncomment below and comment firt line before
#while [ ! -f $FILE ]
#do
#	ls
#	read -p "file name similar to > aura-bin[...].pkg.tar.zst: " FILE
#done
#echo "this file exist"
#sudo pacman -U "$FILE"


sleep 2 && echo "Starting installation..." && sleep 2

# install base-devel (building, compiling, linking)
sudo aura -S --noconfirm --needed wget git openssh

# choose video driver

echo "1) xf86-video-intel 2) nvdia 3) [nvidia - intel]-> prime"
read -r -p "Choose your video card driver (Default 1) Warn: choose integrated gpu driver, discret gpu driver for later: " vid
case $vid in
	[1])
		DRI='xf86-video-intel';;
	[2])
		DRI='nvidia nvidia-settings nvidia-utils';;
	[3])
		DRI='xf86-video-intel nvidia nvidia-settings nvidia-utils nvidia-lts nvidia-prime';;
	[*])
		DRI='xf86-video-intel';;
esac

#install xorg and related
sudo aura -S --noconfirm --needed xorg intel-ucode lightdm lightdm-gtk-greeter xmonad xmonad-contrib $DRI

#Install network packages ### 
sudo aura -S --noconfirm --needed avahi network-manager-applet openssh iw

# Install battery related programs
sudo aura -S --noconfirm --needed acpi

#Install sound related packages and applications ### alsa linux kernel components ### pulseaudio large app. distribution.
# volume systray is installed with AUR.
sudo aura -S --noconfirm --needed alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez-utils pavucontrol

# Install applications from archlinux repo. 
sudo aura -S --noconfirm --needed ranger task libreoffice-still htop vlc alacritty tree redshift stow neofetch zathura zathura-pdf-poppler discord nitrogen dunst cbatticon python-ueberzug

echo 'Installing AUR packages now...' && sleep 1
#Installation of application by AURA
sudo $HELPER -A  --noconfirm --needed volctl clearine-git lightdm-webkit-theme-aether auto-cpufreq google-chrome xmind-2020 onedrive-abraunegg polybar xmonad-log picom-ibhagwan-git dmenu-extended-git lux

sudo systemctl enable lightdm

#Dotfile installation
echo "Checking if necessary directory are created and if not, creating them."
mkdir -vp ~/.config

echo "'.config' directory is in place"
echo "Dotfile configuration installation"
sleep 1 && echo "installation..."
#git clone https://github.com/ezeldar12/dotfiles.git ~/.dotfiles
cd ~/.dotfiles/stow
echo "Symlink creation via stow"
sleep 1
stow -vt ~ xmonad
stow -vt ~ redshift
stow -vt ~ polybar
stow -vt ~ xprofile
stow -vt ~ picom
stow -vt ~ alacritty
stow -vt ~ ranger
stow -vt ~ bin
stow -vt ~ eduroam_generated
stow -vt ~ task
stow -vt ~ studyflash_cardfiles
echo "Configurations are in place"
echo "check PRIME render offload; PCI-Express Runtime D3 (RTD3) Power Management; Prime synchronization"
xmonad --recompile

echo "when login in next time : home+shift+q to restart xmonad. "  && sleep 5
#echo "xmonad restarting... in 3 secondes" && sleep 3 

echo "Rebooting needed... " && sleep 10




	
