# Install yay
# echo "Installing AUR helper (yay)..."
# sudo pacman -S git go --noconfirm || abort "Failed to install dependencies."
# cd /opt
# git clone https://aur.archlinux.org/yay-git.git || abort "Failed to clone yay."
# cd yay-git
# makepkg -siA || abort "Failed to install yay."

# Getting dotfiles
echo "Getting dotfiles..."
git clone https://git.wxllow.dev/wxllow/dotfiles ~/.dotfiles || abort "Failed to clone dotfiles."
cd ~/.dotfiles
./install || abort "Failed to install dotfiles."
