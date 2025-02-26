#!/bin/sh

riverctl spawn 'export XDG_CURRENT_DESKTOP=river'
riverctl spawn 'systemctl --user restart xdg-desktop-portal'
riverctl spawn 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP'

riverctl map normal Super Return spawn alacritty
riverctl map normal Super C spawn wofi
riverctl map normal Super E spawn thunar
riverctl map normal Super+Shift F toggle-float
riverctl map normal Super F toggle-fullscreen
riverctl map normal Super+Shift R spawn "~/.config/river/init"
riverctl map normal Super Q close

# Change output
riverctl map normal Super O spawn "riverctl focus-output next"
# Send to next output
riverctl map normal Super+Shift O spawn "riverctl send-to-output next"

# Exit river
riverctl map normal Super+Shift Q exit

# Shutdown
riverctl map normal Super+Alt Q spawn "shutdown now"

# Super+J and Super+K to focus the next/previous view in the layout stack
riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous

# Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
# view in the layout stack
riverctl map normal Super+Shift J swap next
riverctl map normal Super+Shift K swap previous

# Super+H and Super+L to decrease/increase the main ratio of rivertile(1)
riverctl map normal Super H send-layout-cmd rivertile "main-ratio -0.05"
riverctl map normal Super L send-layout-cmd rivertile "main-ratio +0.05"

# Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
riverctl map normal Super+Alt H send-layout-cmd rivertile "main-count +1"
riverctl map normal Super+Alt L send-layout-cmd rivertile "main-count -1"

# Super+{left,right,up,down} to move views
riverctl map normal Super left move left 100
riverctl map normal Super down move down 100
riverctl map normal Super up move up 100
riverctl map normal Super right move right 100

# Super+Alt+Control+{H,J,K,L} to snap views to screen edges
riverctl map normal Super+Alt+Control H snap left
riverctl map normal Super+Alt+Control J snap down
riverctl map normal Super+Alt+Control K snap up
riverctl map normal Super+Alt+Control L snap right

# Super+Alt+Shif+{left,down,up,right} to resize views
riverctl map normal Super+Shift left resize horizontal -100
riverctl map normal Super+Shift down resize vertical 100
riverctl map normal Super+Shift up resize vertical -100
riverctl map normal Super+Shift right resize horizontal 100

# mouse actions
riverctl map-pointer normal Super BTN_LEFT move-view
riverctl map-pointer normal Super BTN_RIGHT resize-view

for i in $(seq 1 5)
do
    tags=$((1 << ($i - 1)))

    # Super+[1-5] to focus tag [0-5]
    riverctl map normal Super $i set-focused-tags $tags

    # Super+Shift+[1-5] to tag focused view with tag [0-5]
    riverctl map normal Super+Shift $i set-view-tags $tags

    # Super+Ctrl+[1-5] to toggle focus of tag [0-5]
    riverctl map normal Super+Control $i toggle-focused-tags $tags

    # Super+Shift+Ctrl+[1-5] to toggle tag [0-5] of focused view
    riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
done

# Super+0 to focus all tags
# Super+Shift+0 to tag focused view with all tags
all_tags=$(((1 << 32) - 1))
riverctl map normal Super 0 set-focused-tags $all_tags
riverctl map normal Super+Shift 0 set-view-tags $all_tags

# Super+Shift+Alt+{H,J,K,L} to change layout orientation
riverctl map normal Super+Shift+Alt K send-layout-cmd rivertile "main-location top"
riverctl map normal Super+Shift+Alt L send-layout-cmd rivertile "main-location right"
riverctl map normal Super+Shift+Alt J send-layout-cmd rivertile "main-location bottom"
riverctl map normal Super+Shift+Alt H send-layout-cmd rivertile "main-location left"

for mode in normal locked
do
    # Control volume with pamixer
    riverctl map $mode None XF86AudioRaiseVolume  spawn 'pamixer -i 5'
    riverctl map $mode None XF86AudioLowerVolume  spawn 'pamixer -d 5'
    riverctl map $mode None XF86AudioMute         spawn 'pamixer -t'

    # Control MPRIS aware media players with playerctl
    riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPlay  spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPrev  spawn 'playerctl previous'
    riverctl map $mode None XF86AudioNext  spawn 'playerctl next'

    # Control screen backlight brightness with brightnessctl
    riverctl map $mode None XF86MonBrightnessUp   spawn 'brightnessctl set 5%+'
    riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'

    # Screenshot
    riverctl map $mode None Print spawn 'grim -g "$(slurp)" - | swappy -f -'
done

# Set background and border color
riverctl border-color-focused 0xfe8019
riverctl border-color-unfocused 0x928374
riverctl border-width 4

# Set repeat rate
riverctl set-repeat 100 300

riverctl focus-follows-cursor normal

# Make certain views start floating
riverctl float-filter-add app-id float
riverctl float-filter-add app-id wofi
riverctl float-filter-add app-id pavucontrol
riverctl float-filter-add app-id brave title "Save File"
riverctl float-filter-add app-id brave title "Open File"
riverctl float-filter-add app-id blueman-manager
riverctl float-filter-add app-id xdg-desktop-portal-gtk
riverctl float-filter-add app-id xdg-desktop-portal-kde
riverctl float-filter-add app-id org.kde.polkit-kde-authentication-agent-1
riverctl float-filter-add title "Steam - Self Updater"
riverctl float-filter-add title "Picture-in-Picture"
riverctl float-filter-add app-id wofi

# The scratchpad will live on an unused tag. Which tags are used depends on your
# config, but rivers default uses the first 9 tags.
scratch_tag=$((1 << 20 ))

# Toggle the scratchpad with Super+P
riverctl map normal Super P toggle-focused-tags ${scratch_tag}

# Send windows to the scratchpad with Super+Shift+P
riverctl map normal Super+Shift P set-view-tags ${scratch_tag}

# Set spawn tagmask to ensure new windows don't have the scratchpad tag unless
# explicitly set.
all_but_scratch_tag=$(( ((1 << 32) - 1) ^ $scratch_tag ))
riverctl spawn-tagmask ${all_but_scratch_tag}

bash $HOME/.config/river/process.sh

# usage: import-gsettings
config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
if [ ! -f "$config" ]; then exit 1; fi

gnome_schema="org.gnome.desktop.interface"
gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"