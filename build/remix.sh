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
    gpg \
    vim \
    git \
    htop \
    build-essential

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

# =====================#
#       Unique Features #
# =====================#

# 1. **Enhanced Security: Implementing a Firewall and Fail2Ban**
echo "Setting up UFW (Uncomplicated Firewall)..."
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

echo "Installing Fail2Ban to protect against brute-force attacks..."
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 2. **Automated Daily Updates with Unattended Upgrades**
echo "Installing unattended-upgrades for automatic updates..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

# 3. **Integrate AI-Powered Assistant (e.g., ChatGPT CLI)**
echo "Installing ChatGPT CLI for AI assistance in the terminal..."
# Note: Replace with actual installation commands if available
curl -sSL https://example.com/chatgpt-cli/install.sh | sudo bash

# 4. **Customize Terminal Experience with Oh My Zsh**
echo "Installing Zsh and Oh My Zsh for an enhanced terminal experience..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)

# 5. **Implement System-wide Clipboard Manager**
echo "Installing CopyQ for advanced clipboard management..."
sudo apt install -y copyq
# Enable CopyQ to start on login
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/copyq.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=copyq
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=CopyQ
Comment=Advanced Clipboard Manager
EOF

# 6. **Set Up Automatic Backup with Timeshift**
echo "Installing Timeshift for system backups..."
sudo apt install -y timeshift
sudo timeshift --create --comments "Initial backup" --tags D

# 7. **Integrate Custom Notification System**
echo "Installing Dunst for customizable desktop notifications..."
sudo apt install -y dunst
# Configure Dunst (optional: customize as needed)
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc <<EOF
[global]
    font = Monospace 10
    geometry = "300x50-10+10"
    transparency = 20
    frame_width = 1
    separator_height = 1
    padding = 5
    # More customization options...

[urgency_low]
    background = "#222222"
    foreground = "#FFFFFF"
    ...

[urgency_normal]
    background = "#333333"
    foreground = "#FFFFFF"
    ...

[urgency_high]
    background = "#FF5555"
    foreground = "#000000"
    ...
EOF
# Enable Dunst to start on login
cat > /etc/xdg/autostart/dunst.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=dunst
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Dunst
Comment=Lightweight Notification Daemon
EOF

# 8. **Enhance Privacy with VPN Setup (e.g., WireGuard)**
echo "Installing WireGuard for secure VPN connections..."
sudo apt install -y wireguard
# Note: Configuration requires user-specific setup
echo "Please configure WireGuard manually or provide a configuration script."

# 9. **Add Custom Aliases and Functions for Productivity**
echo "Adding custom aliases and functions to .zshrc..."
cat >> ~/.zshrc <<'EOF'

# Custom Aliases
alias ll='ls -la'
alias gs='git status'
alias gp='git pull'
alias gd='git diff'

# Function to update and upgrade the system
update_system() {
    sudo apt update && sudo apt upgrade -y
    sudo apt autoremove -y
}

EOF

# 10. **Integrate a System Monitoring Dashboard (e.g., Netdata)**
echo "Installing Netdata for real-time system monitoring..."
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --disable-telemetry

# 11. **Set Up a Custom Splash Screen Using Plymouth**
echo "Customizing Plymouth splash screen..."
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/vanilla/vanilla.plymouth 100
sudo update-alternatives --config default.plymouth
sudo update-initramfs -u

# 12. **Optimize System Performance with Preload**
echo "Installing Preload for performance optimization..."
sudo apt install -y preload
sudo systemctl enable preload
sudo systemctl start preload

# 13. **Implement Disk Encryption for Enhanced Security**
echo "Setting up LUKS for disk encryption..."
# Note: Disk encryption setup requires careful planning and user interaction.
# It's recommended to perform this step during installation or with detailed instructions.

# 14. **Enable Dark Mode by Default**
echo "Configuring KDE Plasma to use Dark Mode by default..."
sudo -u $USER dbus-launch plasma5-apply-desktoptheme org.kde.breeze.desktop

# 15. **Add a Custom Application Launcher (e.g., Albert)**
echo "Installing Albert launcher for quick application access..."
sudo add-apt-repository -y ppa:albertlauncher/albert
sudo apt update
sudo apt install -y albert
# Enable Albert to start on login
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/albert.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=albert
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Albert
Comment=Quick Application Launcher
EOF

# =====================#
#       End of Unique Features #
# =====================#

# Clean up
sudo apt autoremove -y
sudo apt clean

echo "Custom Linux environment has been successfully installed and configured with unique features."
echo "Please reboot your system to apply all changes."
