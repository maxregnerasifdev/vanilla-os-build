#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Function to add a repository and handle errors
add_repo() {
    local repo=$1
    sudo add-apt-repository -y --no-update "$repo"
}

# Add universe and multiverse repositories
add_repo universe
add_repo multiverse

# Update package lists
sudo apt update

# Install essential utilities
sudo apt install -y \
    capuser \
    expect \
    curl \
    gpg

# Install Vanilla OS PPA
curl -s --compressed "https://vanilla-os.github.io/ppa/KEY.gpg" | gpg --dearmor | sudo tee /usr/share/keyrings/vanilla-archive-keyring.gpg > /dev/null
sudo curl -s --compressed -o /etc/apt/sources.list.d/vanilla-os.list "https://vanilla-os.github.io/ppa/vanilla-os.list"
sudo apt update

# Install KDE Plasma desktop environment and related packages
sudo apt install -y \
    kde-plasma-desktop \
    plasma-desktop \
    kde-standard \
    bluedevil \
    systemsettings \
    kdeconnect \
    dolphin \
    okular \
    kate \
    kwrite \
    konsole \
    kwin-x11 \
    sddm \
    fonts-noto \
    --no-install-recommends

# Install additional utilities and drivers
sudo apt install -y -f
sudo apt purge -y ubuntu-desktop ubuntu-session

# Set SDDM as the default display manager
echo "sddm" | sudo tee /etc/X11/default-display-manager

# Enable and start SDDM service
sudo systemctl enable sddm
sudo systemctl start sddm

# Set default wallpaper for KDE Plasma
mkdir -p ~/.local/share/plasma/backgrounds/
cp /usr/share/backgrounds/gnome/adwaita-l.jpg ~/.local/share/plasma/backgrounds/kde-default-wallpaper.jpg

# Configure Plasma to use the new wallpaper
cat > ~/.config/plasma-org.kde.plasma.desktop-appletsrc <<EOF
[Wallpaper]
Image=file:///usr/share/backgrounds/gnome/adwaita-l.jpg

[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/backgrounds/gnome/adwaita-l.jpg
EOF

# Remove pre-installed snap packages to prevent conflicts
sudo snap remove --purge firefox
sudo snap remove --purge snap-store

# Install Flatpak and enable Flathub repository
sudo apt install -y flatpak
sudo flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Vanilla OS First Setup
sudo apt install -y vanilla-first-setup
mkdir -p /etc/skel/.config/autostart
if [ -f /usr/share/applications/io.github.vanilla-os.FirstSetup.desktop ]; then
    sudo cp /usr/share/applications/io.github.vanilla-os.FirstSetup.desktop /etc/skel/.config/autostart/
else
    sudo cp /usr/local/share/applications/io.github.vanilla-os.FirstSetup.desktop /etc/skel/.config/autostart/
fi

# Install Vanilla OS Plymouth theme
sudo apt install -y plymouth-theme-vanilla

# Install Vanilla OS distrologo
sudo apt install -y vanilla-distrologo

# Clean up
sudo apt autoremove -y
sudo apt clean

echo "KDE Plasma desktop environment has been successfully installed and configured."
echo "Please reboot your system to apply all changes."
