TIMEZONE="America/New_York"
HOSTNAME="arch"
USERNAME="wl"
EXTRAS="neovim git vim neofetch wget mpv chromium kitty lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings pipewire-jack pipewire-alsa pipewire-pulse"
DRIVE="/dev/sda"
LOCALE="en_US.UTF-8"
PREFFERED_SHELL="zsh"

abort() {
    echo "${1} Aborting..."
    exit 1
}

# Update mirrors
echo "Updating mirrors..."
pacman -Sy --noconfirm || abort "Failed to update mirrors."

# Install yay
echo "Installing AUR helper (yay)..."
sudo pacman -S git go --noconfirm || abort "Failed to install dependencies."
cd /opt
git clone https://aur.archlinux.org/yay-git.git || abort "Failed to clone yay."
cd yay-git
makepkg -siA || abort "Failed to install yay."

# Install and enable NetworkManager
echo "Installing and enabling NetworkManager..."
pacman -S networkmanager --noconfirm || abort "Failed to install NetworkManager."
systemctl enable NetworkManager.service || abort "Failed to enable NetworkManager."

# Install extra packages
echo "Installing extra packages..."
pacman -S $EXTRAS --noconfirm || abort "Failed to install extra packages."

# Timezone
echo "Setting timezone to ${TIMEZONE}..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime || abort "Failed to set timezone."
hwclock --systohc

# Locale
echo "Setting/generating locale..."
echo $LOCALE >>/etc/locale.gen
echo $LOCALE >>/etc/locale.conf
locale-gen || abort "Failed to generate locale."

# Hostname
echo "Setting hostname to ${HOSTNAME}..."
echo $HOSTNAME >/etc/hostname

# Setting root password
echo "Please set a root password..."
passwd root || abort "Failed to set root password."

# Creating user
echo "Creating user ${USERNAME} with wheel group..."
useradd -m -G wheel $USERNAME || abort "Failed to create user."

# Setting user password
echo "Please set a password for ${USERNAME}..."
passwd $USERNAME || abort "Failed to set user password."

# Install doas
echo "Installing doas..."
pacman -S doas --noconfirm || abort "Failed to install doas."

echo "Setting up doas..."
echo 'permit persist :wheel' >/etc/doas.conf

echo "Removing sudo..."
pacman -R sudo --noconfirm || abort "Failed to remove sudo."
ln -s /usr/bin/doas /usr/bin/sudo || abort "Failed to set up doas."

echo "Changing shell to ${PREFFERED_SHELL}..."
chsh -s $PREFFERED_SHELL || abort "Failed to change shell."

# Getting dotfiles
echo "Getting dotfiles..."
cd "/home/${USERNAME}"
git clone https://git.wxllow.dev/wxllow/dotfiles .dotfiles || abort "Failed to clone dotfiles."
cd .dotfiles
./install || abort "Failed to install dotfiles."

# TODO: Support x86_64
# Install grub
echo "Installing and setting up grub..."
pacman -S grub efibootmgr os-prober --noconfirm || abort "Failed to install grub."
grub-install --target=arm64-efi --bootloader-id=grub_uefi --efi-directory=/boot --recheck $DRIVE || abort "Failed to set up grub. "
grub-mkconfig -o /boot/grub/grub.cfg || abort "Failed to generate grub.cfg."
os-prober || abort "Failed to run os-prober."
echo "Installation is complete! Please reboot."
