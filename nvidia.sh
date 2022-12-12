#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./nvidia.sh or ./amd.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)
hostname=Fedora_Office

#Blender variables
blenderurl=https://www.blender.org/download/release/Blender3.4/blender-3.4.0-linux-x64.tar.xz/
blenderfile=blender-3.4.0-linux-x64

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

#Set hostname
sudo hostnamectl set-hostname "$hostname"

# Installing Essential Programs 
sudo dnf install xdg-user-dirs cups gnome-calculator openssh-server numlockx gimp freecad bspwm sxhkd xev kitty rofi xsetroot polybar picom thunar nitrogen zip unzip mpv yad wget pavucontrol blueman network-manager-applet -y
# Installing Other less important Programs
sudo dnf install neofetch @virtualization prusa-slicer arandr subversion mod_dav_svn git vim flameshot lxappearance papirus-icon-theme cmatrix -y
# Installing Gaming-related stuff
sudo dnf install steam discord protonup gamemode lutris mangohud -y

# Install Joplin Notebook
sudo dnf install -y dnf-plugins-core distribution-gpg-keys -y
sudo dnf copr enable taw/joplin
sudo dnf install -y joplin -y

# WORK-RELATED STUFF
# SSTP VPN, Citrix Workspace client, Teamviewer, Outlook client, OnlyOffice + Microsoft Teams
cd rpm/
sudo dnf install sstp-client -y
sudo dnf install NetworkManager-sstp -y
sudo dnf install NetworkManager-sstp-gnome -y
sudo dnf install rpm/ICAClient-rhel-22.12.0.12-0.x86_64.rpm -y

wget https://github.com/julian-alarcon/prospect-mail/releases/download/v0.4.0/prospect-mail-0.4.0.x86_64.rpm
sudo dnf install prospect-mail-0.4.0.x86_64.rpm -y

wget https://packages.microsoft.com/yumrepos/ms-teams/teams-1.5.00.23861-1.x86_64.rpm
sudo dnf install teams-1.5.00.23861-1.x86_64.rpm -y

wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors.x86_64.rpm
sudo dnf install onlyoffice-desktopeditors.x86_64.rpm -y

wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm
sudo dnf install teamviewer.x86_64.rpm -y


# Cursor
sudo dnf copr enable peterwu/rendezvous -y
sudo dnf install bibata-cursor-themes -y

# Install and enable SDDM
sudo dnf install sddm -y
sudo systemctl set-default graphical.target

# Nvidia drivers with CUDA
sudo dnf update --refresh -y
sudo dnf install akmod-nvidia -y
sudo dnf install xorg-x11-drv-nvidia-cuda -y
sudo dnf install xorg-x11-drv-nvidia-cuda-libs -y

# Install brave-browser
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ -y
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc -y
sudo dnf install brave-browser -y

# Preload deamon
#sudo dnf copr enable kylegospo/preload -y
#sudo dnf install preload -y
#sudo systemctl enable --now preload

# Install Blender
mkdir -p {~/.local/bin,~/.local/share/applications/} && cd ~/.local/bin
wget $blenderurl
tar xpf ~/.local/bin/$blenderfile.tar.xz
sudo ln -sf ~/.local/bin/$blenderfile/blender ~/.local/bin/blender
cp ~/.local/bin/$blenderfile/blender.desktop ~/.local/share/applications/

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

# WIP - Security (firewalld already installed)
sudo dnf install fail2ban -y
#Edit /etc/fail2ban/jail.local to add log-paths ect.

# Enable services
sudo systemctl enable sddm
sudo systemctl enable sshd
sudo systemctl enable fail2ban
sudo systemctl enable libvirtd
sudo systemctl enable cups.service
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

usermod -aG libvirt $username
sudo virsh net-autostart default


# Reloading Fonts
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip

reboot
