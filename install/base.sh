TARGET_DRIVE="/dev/sda"
TARGET_BOOT_PARTITION="${TARGET_DRIVE}1"
TARGET_ROOT_PARTITION="${TARGET_DRIVE}2"

# Confirm
read -p "Do you want to proceed? (y) " yn

abort() {
    echo "${1}Aborting..."
    exit 1
}
case $yn in
y) ;;
*)
    abort
    ;;
esac

# Update mirrors
echo "Updating mirrors..."
pacman -Sy --noconfirm || abort "Failed to update mirrors. "

# Enable NTP
echo "Enabling NTP..."
timedatectl set-ntp true || abort "Failed to enable NTP. "

# Formatting partitions
echo "Opening cfdisk..."
echo "cfdisk ${TARGET_DRIVE}" || abort "cfdisk failed. "

echo "Formatting partitions..."
mkfs.fat -F 32 $TARGET_BOOT_PARTITION || abort "Failed to format boot partition. "
mkfs.ext4 $TARGET_ROOT_PARTITION || abort "Failed to format root partition. "

echo "Mounting partitions..."
mount $TARGET_ROOT_PARTITION /mnt || abort "Failed to mount root partition. "
mount --mkdir $TARGET_BOOT_PARTITION /mnt/boot || abort "Failed to mount boot partition. "

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware base-devel || abort "Failed to install base system. "

# Generating fstab
echo "Generating fstab..."
genfstab -U /mnt >>/mnt/etc/fstab || abort "Failed to generate fstab. "

# Chroot
echo "Chrooting... Please run install/alarm.sh or install/x64.sh in the chroot environment."
arch-chroot /mnt || abort "Failed to chroot. "
