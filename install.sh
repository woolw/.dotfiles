#!/bin/sh

install_stage=(
    hyprland
    hyprpaper
    dunst
    stow
    qt5-wayland
    qt5ct
    qt6-wayland
    qt6ct
    pipewire
    wireplumber
    wl-clipboard
    cliphist   
    alacritty
    waybar
    wofi
    xdg-desktop-portal-hyprland
    grim
    slurp
    thunar
    steam
    brave-bin
    ani-cli
    mpv
    pamixer
    pavucontrol
    brightnessctl
    bluez
    bluez-utils
    blueman
    network-manager-applet
    ttf-jetbrains-mono-nerd
    noto-fonts-emoji
    xfce4-settings
    vulkan-radeon
    lib32-vulkan-radeon
)

# function that will test for a package and if not found it will attempt to install it
install_software() {
    yay -S --noconfirm --needed $1 &
}

if [ ! -f /sbin/yay ]; then  
    git clone https://aur.archlinux.org/yay.git &
    cd yay
    makepkg -si --noconfirm &
    yay -Suy --noconfirm &
fi

for SOFTWR in ${install_stage[@]}; do
    install_software $SOFTWR 
done

sudo systemctl enable --now bluetooth.service &

stow hypr &
stow waybar &

exit