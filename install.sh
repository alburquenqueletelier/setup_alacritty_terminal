#!/bin/bash
set -e

#This script was created for only for Debian 13 systems to automate the installation of essential packages and configurations.
#There is no guarantee that this will work on other Debian-based distributions or versions.

# Update package lists
echo "Updating package lists..."
sudo apt update 

## Ask for upgrade
read -p "Do you want to upgrade existing packages? (y/n): " upgrade_choice
if [[ "$upgrade_choice" == "y" || "$upgrade_choice" == "Y" ]]; then
    echo "Upgrading existing packages..."
    sudo apt upgrade -y
fi

# Install necessary packages
echo "Installing necessary packages..."
sudo apt install -y git curl wget build-essential zsh zip unzip gpg cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 rustup gzip scdoc

echo "Installing visual studio code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg

echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
" > vscode.sources

sudo apt install apt-transport-https &&
sudo apt update &&
sudo apt install -y code # or code-insiders

echo "Git Setup"


echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Setting up Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi

echo "Setting up Oh My Zsh with powerlevel10k..."
if [ ! -d "$HOME/powerlevel10k" ]; then
    echo "Setting up Oh My Zsh with powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
else
    echo "Powerlevel10k is already installed."
fi

P10K_LINE='source ~/powerlevel10k/powerlevel10k.zsh-theme'
if ! grep -Fxq "$P10K_LINE" ~/.zshrc; then
    echo "$P10K_LINE" >> ~/.zshrc
fi

echo "Installing Meslol Nerd Font..."
FONT_DIR="/home/${SUDO_USER:-$USER}/.local/share/fonts"
mkdir -p "$FONT_DIR" || { echo "Failed to create font directory"; exit 1; }
if [ ! -f "$FONT_DIR/Meslo.zip" ]; then
    echo "Downloading Meslo Nerd Font..."
    wget -O "$FONT_DIR/Meslo.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip || { echo "Failed to download Meslo.zip"; exit 1; }
else
    echo "Meslo Nerd Font already downloaded."
fi

if [ ! -d "$FONT_DIR/Meslo" ]; then
    echo "Extracting Meslo Nerd Font..."
    unzip -o "$FONT_DIR/Meslo.zip" -d "$FONT_DIR" || { echo "Failed to unzip Meslo.zip"; rm -f "$FONT_DIR/Meslo.zip"; exit 1; }
    rm "$FONT_DIR/Meslo.zip" # Eliminar el archivo zip después de la extracción
else
    echo "Meslo Nerd Font is already extracted."
fi

fc-cache -fv || { echo "Failed to refresh font cache"; exit 1; }

cd || { echo "Failed to return to home directory"; exit 1; }

echo "Meslo Nerd Font installation completed."

## Install Alacritty Terminal
echo "Installing Alacritty terminal..."

rustup default stable
rustc --version
cargo --version

ALACRITTY_DIR="$HOME/alacritty"
if [ -d "$ALACRITTY_DIR" ]; then
    echo "Removing existing Alacritty directory..."
    rm -rf "$ALACRITTY_DIR" || { echo "Failed to remove existing Alacritty directory"; exit 1; }
fi
git clone https://github.com/alacritty/alacritty.git "$ALACRITTY_DIR" || { echo "Failed to clone Alacritty repository"; exit 1; }
cd "$ALACRITTY_DIR" || { echo "Failed to enter Alacritty directory"; exit 1; }
cargo build --release || { echo "Failed to build Alacritty"; exit 1; }

infocmp "alacritty" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Terminfo already installed."
else
    echo "Terminfo not installed."
    echo "Installing terminfo..."
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
fi
sudo cp target/release/alacritty /usr/local/bin
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null


ZSH_FUNCTIONS_DIR="${ZDOTDIR:-$HOME}/.zsh_functions"
mkdir -p "$ZSH_FUNCTIONS_DIR"
FPATH_LINE='fpath+=${ZDOTDIR:-~}/.zsh_functions'
if ! grep -Fxq "$FPATH_LINE" "${ZDOTDIR:-$HOME}/.zshrc"; then
    echo "$FPATH_LINE" >> "${ZDOTDIR:-$HOME}/.zshrc"
fi
cp extra/completions/_alacritty "$ZSH_FUNCTIONS_DIR/_alacritty"

echo "Installing themes..."
git clone 

chsh -s $(which zsh)

echo "Installation and configuration complete! Please restart your terminal."
