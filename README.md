# .dotfiles


######################################################################
Onedrive github with the documentation. 
----------------------------------------------------
https://github.com/abraunegg/onedrive
######################################################################
PRIME render offload && PCI-Express Runtime D3 (RTD3) Power Management
----------------------------------------------------
/etc/udev/rules.d/80-nvidia-pm.rules
# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
--------------------------------------------------
/etc/modprobe.d/nvidia-pm.conf
options nvidia "NVreg_DynamicPowerManagement=0x02"
--------------------------------------------------
We also need to enable the nvidia-persistenced
--------------------------------------------------

#####################################################################
https://www.youtube.com/watch?v=Xek3TGKzLWw
SETUP HIBERNATION ON LINUX WITH GRUB

i. Suspend, Hibernate, Sleep

1. Make sure you have a swap partition of swap file
    a) lsblk to get partition

2. Pass swap location to kernel
    a) sudo $EDITOR /etc/default/grub
    b) kernel param: resume=/dev/sdXx
    c) sudo grub-mkconfig -o /boot/grub/grub.cfg

 3. Switch behaviours
     a) sudo $EDITOR /etc/systemd/logind.conf
     b) sudo systemctl restart systemd-logind
#############################################
