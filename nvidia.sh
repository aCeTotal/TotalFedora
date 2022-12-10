#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./nvidia.sh or ./amd.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)
hostname=Fedora_Office

# Enable parallell download and choose the fastest mirrors

cat > /etc/dnf/dnf.conf << EOF
[main]
color=always
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
max_parallel_downloads=20
fastestmirror=True
deltarpm=true
EOF

# Update packages list and update system + adding rpmfusion repo
sudo dnf update -y
sudo dnf upgrade --refresh -y
sudo dnf install dnf-plugins-core -y

#Enable RPM FUSION
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y

sudo dnf install \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

sudo dnf update --refresh -y

# Media codecs
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y
sudo dnf install lame\* --exclude=lame-devel -y
sudo dnf group upgrade --with-optional Multimedia -y

# Making .config and Moving config files and background to Pictures
cd $builddir
mkdir -p /home/$username/.config
mkdir -p /home/$username/.fonts
mkdir -p /home/$username/Dokumenter/
mkdir -p /home/$username/Downloads/
mkdir -p /home/$username/Bilder/
mkdir -p /home/$username/Bilder/Screenshots/
mkdir -p /home/$username/Bilder/Wallpapers/
mkdir -p /usr/share/sddm/themes
cp -R dotconfig/* /home/$username/.config/
tar -xzvf sugar-candy.tar.gz -C /usr/share/sddm/themes

#Set hostname
sudo hostnamectl set-hostname "$hostname"

# Installing Essential Programs 
sudo dnf install xdg-user-dirs gimp freecad bspwm sxhkd xev kitty rofi polybar picom thunar nitrogen zip unzip mpv yad wget pavucontrol blueman network-manager-applet -y
# Installing Other less important Programs
sudo dnf install neofetch prusa-slicer arandr git vim flameshot lxappearance papirus-icon-theme -y
# Installing Gaming-related stuff
sudo dnf install steam discord protonup gamemode lutris mangohud -y

# Install Joplin Notebook
sudo dnf install -y dnf-plugins-core distribution-gpg-keys -y
sudo dnf copr enable taw/joplin
sudo dnf install -y joplin -y

#SSTP VPN, Citrix Workspace client, Outlook client, OnlyOffice + Microsoft Teams
cd rpm/
sudo dnf install sstp-client -y
sudo dnf install NetworkManager-sstp -y
sudo dnf install NetworkManager-sstp-gnome -y
sudo dnf install rpm/ICAClient-rhel-22.12.0.12-0.x86_64.rpm -y
sudo dnf install rpm/prospect-mail-0.4.0.x86_64.rpm -y
sudo dnf install rpm/teams-1.5.00.23861-1.x86_64.rpm -y
wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors.x86_64.rpm
sudo dnf install onlyoffice-desktopeditors.x86_64.rpm -y && cd ..

# Cursor
sudo dnf copr enable peterwu/rendezvous -y
sudo dnf install bibata-cursor-themes -y

# Install and enable SDDM
sudo dnf install lightdm -y
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# Nvidia drivers
sudo dnf update --refresh -y
sudo dnf install akmod-nvidia -y
sudo dnf install xorg-x11-drv-nvidia-cuda -y
sudo dnf install xorg-x11-drv-nvidia-cuda-libs -y

# Install brave
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ -y
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc -y
sudo dnf install brave-browser -y

# Preload deamon
sudo dnf copr enable kylegospo/preload -y
sudo dnf install preload -y
sudo systemctl enable --now preload

# Install blender
mkdir ~/blender-git
mkdir ~/blender-git/lib
cd ~/blender-git
git clone https://git.blender.org/blender.git
svn checkout https://svn.blender.org/svnroot/bf-blender/trunk/lib/linux_centos7_x86_64
cd blender
make update
make

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

# Security
sudo dnf install fail2ban -y
sudo systemctl enable fail2ban && sudo systemctl start fail2ban
#Edit /etc/fail2ban/jail.local

# Enable services


# Reloading Fonts
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip

reboot
