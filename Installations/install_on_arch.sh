#!/bin/env bash

set -e  #stop stops the excecution of script if command or pipeline has an error.

echo "Welcome Acerola!" && sleep 2


#Default var 
HELPER="aura"
FILE="iDoNotExist"

# full system update, just in case ;)
echo "Doing a system update... Stuff may break if not the lastest version..."
sudo pacman --noconfirm -Syu  #--noconfirm will bypass "are you sure?"

sleep 2 && echo "Starting installation..." && sleep 2

# install base-devel (building, compiling, linking)
sudo pacman -S --noconfirm --needed base-devel wget git openssh

# choose video driver

echo "1) xf86-video-intel 2) nvdia 3) skip"
read -r -p "Choose your video card driver (Default 1) Warn: choose integrated gpu driver, discret gpu driver for later." vid
case $vid in
	[1])
		DRI='xf86-video-intel';;
	[2])
		DRI='nvidia nvidia-settings nvidia-utils';;
	[3])
		DRI='xf86-video-intel nvidia nvidia-setting nvidia-utils nvidia-lts nvidia-prime';;
	[*])
		DRI='xf86-video-intel';;
esac

#install xorg and related
sudo pacman -S --noconfirm --needed xorg intel-ucode lightdm lightdm-gtk-greeter xmonad xmonad-contrib picom $DRI nitrogen xmonad-log

#Install network packages ### 
sudo pacman -S --noconfirm --needed avahi network-manager-applet openssh iw

# Install battery related programs
sudo pacman -S --noconfirm --needed acpi

#Install sound related packages and applications ### alsa linux kernel components ### pulseaudio large app. distribution.
# volume systray is installed with AUR.
sudo pacman -S --noconfirm --needed alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez-utils pavucontrol

# Install applications from pacman repo. 
sudo pacman -S --noconfirm --needed ranger htop vlc alacritty tree redshift stow neofetch zathura 

echo "AUR installation, $HELPER is being installed"
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin && makepkg

while [ ! -f $FILE ]
do
	ls
	read -p "file name similar to > aura-bin[...].pkg.tar.zst: " FILE
done
echo "this file exist"
sudo pacman -U "$FILE"

#Installation of application by AURA
sudo $HELPER -A  volctl\
		 auto-cpufreq\
		 google-chrome\
		 discord\
		 timeshift\
		 xmind-2020\
		 onedrive-abraunegg





#Dotfile installation
echo "Checking if necessary directory are created and if not, creating them."
mkdir -vp ~/.config

echo "'.config' directory is in place"
echo "Dotfile configuration installation"
sleep 1 && echo "installation..."
git clone https://github.com/ezeldar12/dotfiles.git ~/.dotfiles
cd ~/.dotfiles/stow
echo "Symlink creation via stow"
sleep 1
stow -vt ~ xmonad
stow -vt ~ vim
stow -vt ~ redshift
stow -vt ~ polybar
stow -vt ~ xprofile

echo "Configurations are in place"
echo "check PRIME render offload; PCI-Express Runtime D3 (RTD3) Power Management; Prime synchronization"
xmonad --recompile


	
