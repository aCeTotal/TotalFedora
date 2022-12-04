#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./nvidia.sh or ./amd.sh" 2>&1
  exit 1
fi

username=$(whoami)
builddir=$(pwd)

# Update packages list and update system + adding rpmfusion repo
sudo dnf update -y
sudo dnf upgrade --refresh -y
sudo dnf install dnf-plugins-core -y

sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf update --refresh -y

# Making .config and Moving config files and background to Pictures
cd $builddir
mkdir -p /home/$username/.config
mkdir -p /home/$username/.fonts
mkdir -p /home/$username/Dokumenter/
mkdir -p /home/$username/Downloads/
mkdir -p /usr/share/sddm/themes
cp -R dotconfig/* /home/$username/.config/
tar -xzvf sugar-candy.tar.gz -C /usr/share/sddm/themes
mv /home/$username/.config/sddm.conf /etc/sddm.conf

# Installing Essential Programs 
sudo dnf install xdg-user-dirs bspwm sxhkd kitty rofi polybar picom thunar nitrogen unzip yad wget pavucontrol -y
# Installing Other less important Programs
sudo dnf install neofetch arandr git vim flameshot mangohud lxappearance papirus-icon-theme -y
# Installing popular softwares
sudo dnf install blender gimp freecad libreoffice steam discord 

# Install and enable SDDM
sudo dnf install sddm
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

# Nvidia drivers
sudo dnf update --refresh -y
sudo dnf install akmod-nvidia -y
sudo dnf install xorg-x11-drv-nvidia-cuda -y
sudo dnf install xorg-x11-drv-nvidia-cuda-libs -y

# Install brave
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# Installing fonts
cd $builddir 
sudo dnf install fonts-noto-color-emoji fontawesome-fonts fontawesome-fonts-web
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /home/$username/.fonts

# Reloading Fonts
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip

reboot
