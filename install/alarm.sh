TIMEZONE="America/New_York"
HOSTNAME="arch"
USERNAME="wl"
EXTRAS="vim"

abort() {
    echo "${1}Aborting..."
    exit 1
}

echo ":)"

# Install extra packages
echo "Installing extra packages..."
pacman -S $EXTRAS --noconfirm

# Timezone
echo "Setting timezone to ${TIMEZONE}..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime || abort "Failed to set timezone. "
hwclock --systohc

# Locale
echo "Generating locale..."
vim /etc/locale.gen
locale-gen || abort "Failed to generate locale. "

# Hostname
echo "Setting hostname to ${HOSTNAME}..."
echo $HOSTNAME >/etc/hostname

# Setting root password
echo "Please set a root password..."
passwd root || abort "Failed to set root password. "

# Creating user
echo "Creating user ${USERNAME} with wheel group..."
useradd -m -G wheel $USERNAME || abort "Failed to create user. "

# Setting user password
echo "Please set a password for ${USERNAME}..."
passwd $USERNAME || abort "Failed to set user password. "

# Install doas
echo "Installing doas..."
pacman -S doas --noconfirm || abort "Failed to install doas. "

echo "Setting up doas..."
echo 'permit persist :wheel' >/etc/doas.conf

echo "Removing sudo..."
pacman -R sudo --noconfirm || abort "Failed to remove sudo. "
ln -s /usr/bin/doas /usr/bin/sudo || abort "Failed to set up doas. "

# Install grub
echo "Installing and setting up grub..."
pacman -S grub efibootmgr --noconfirm || abort "Failed to install grub. "
grub-install --target=arm64-efi --bootloader-id=grub_uefi --efi-directory=/boot --recheck || abort "Failed to set up grub. "
grub-mkconfig -o /boot/grub/grub.cfg || abort "Failed to generate grub.cfg. "

echo "Installation is complete! Please reboot."
