#!/bin/bash

# Arch Linux Hyprland Dotfiles Installer
# Author: Expert Linux System Architect
# Description: Robust installer for Hyprland dotfiles with smart dependency management

set -e # Exit on any error

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/backup_dots_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
  if ! command -v pacman &>/dev/null; then
    log_error "This script is designed for Arch Linux. pacman not found."
    exit 1
  fi
  log_success "Arch Linux detected"
}

# Select AUR helper or install yay if missing
choose_package_manager() {
  log_info "Choosing AUR package manager..."

  local aurList=("yay" "paru" "yay-bin" "paru-bin")
  local yay_available=false
  local paru_available=false

  for helper in "${aurList[@]}"; do
    if command -v "$helper" &>/dev/null; then
      [[ "$helper" == yay* ]] && yay_available=true
      [[ "$helper" == paru* ]] && paru_available=true
    fi
  done

  if [[ "$yay_available" == true && "$paru_available" == true ]]; then
    echo -e "${YELLOW}Multiple AUR helpers available. Please choose:${NC}"
    for i in "${!aurList[@]}"; do
      if command -v "${aurList[$i]}" &>/dev/null; then
        echo "$((i + 1))) ${aurList[$i]} ✓"
      else
        echo "$((i + 1))) ${aurList[$i]}"
      fi
    done
    echo "0) Skip AUR packages"

    while true; do
      read -p "Enter option [default: 1] | q to quit: " choice
      choice=${choice:-1}
      case $choice in
      q | Q)
        log_info "Quitting..."
        exit 0
        ;;
      0)
        PKG_MANAGER="pacman"
        AUR_HELPER_AVAILABLE=false
        break
        ;;
      [1-4])
        selected_helper="${aurList[$((choice - 1))]}"
        if command -v "$selected_helper" &>/dev/null; then
          PKG_MANAGER="$selected_helper"
          AUR_HELPER_AVAILABLE=true
          break
        else
          log_warning "$selected_helper not installed"
        fi
        ;;
      *) echo -e "${RED}Invalid option.${NC}" ;;
      esac
    done
  else
    echo -e "${YELLOW}No AUR helper found. Install yay? (Recommended)${NC}"
    echo "1) Install yay"
    echo "2) Skip AUR packages"

    while true; do
      read -p "Enter option [default: 1]: " choice
      choice=${choice:-1}
      case $choice in
      1)
        log_info "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        PKG_MANAGER="yay"
        AUR_HELPER_AVAILABLE=true
        break
        ;;
      2)
        PKG_MANAGER="pacman"
        AUR_HELPER_AVAILABLE=false
        break
        ;;
      *) echo -e "${RED}Invalid option.${NC}" ;;
      esac
    done
  fi
}

# Analyze config for additional dependencies
# Note: Log messages are sent to stderr (>&2) to keep the return value clean
analyze_hyprland_deps() {
  local additional_packages=()
  local hypr_conf="$REPO_DIR/.config/hypr/hyprland.conf"

  echo -e "${BLUE}[INFO]${NC} Analyzing hyprland configuration..." >&2

  if [[ -f "$hypr_conf" ]]; then
    local commands=$(grep -E "^exec(-once)?\s*=" "$hypr_conf" | sed -E 's/^exec(-once)?\s*=\s*//' | awk '{print $1}')

    for cmd in $commands; do
      cmd=$(basename "$cmd")
      case "$cmd" in
      "rofi") additional_packages+=("rofi-lbonn-wayland-git") ;;
      "waybar") additional_packages+=("waybar") ;;
      "swaync") additional_packages+=("swaync") ;;
      "nm-applet") additional_packages+=("network-manager-applet") ;;
      "blueman-applet") additional_packages+=("blueman") ;;
      esac
    done
  fi
  echo "${additional_packages[@]}"
}

# Main package installation logic
install_packages() {
  log_info "Installing required packages..."

  local base_packages=(
    "hyprland" "hypridle" "hyprlock" "waybar" "swaync" "kitty" "swww"
    "brightnessctl" "playerctl" "grim" "slurp" "jq" "ttf-jetbrains-mono-nerd"
    "papirus-icon-theme" "network-manager-applet" "polkit-gnome" "swaync"
    "fcitx5" "cava" "ranger" "fastfetch" "starship" "qt6ct"
    "thunar" "rofi" "htop" "wireplumber" "wl-clipboard" "wlogout"
    "libnotify" "python3" "bc" "wget" "atool" "imagemagick" "zsh"
    "blueman" "qt6ct" "nvim" "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "wireplumber" "exa" "pokemon-colorscripts-git" "sl" "cmatrix" "nm-connection-editor" "ttf-firacode-nerd" "which"
  )

  local aur_packages=(
    "rofi-lbonn-wayland-git"
    "fzf"
    "python-pywal16"
    "bibata-cursor-theme"
  )

  # Capture dependencies while ignoring log text
  local additional_packages=($(analyze_hyprland_deps))

  # Merge and filter out any potential log strings like [INFO]
  local all_packages=("${base_packages[@]}" "${additional_packages[@]}")
  local unique_packages=($(printf "%s\n" "${all_packages[@]}" | grep -v "\[INFO\]" | grep -v "Analyzing" | sort -u))

  log_info "Found ${#unique_packages[@]} packages to install"

  if [[ "$AUR_HELPER_AVAILABLE" == true ]]; then
    # Clear potentially corrupted cache (fix for 'not a git repository' error)
    log_info "Cleaning $PKG_MANAGER cache..."
    rm -rf ~/.cache/yay/* 2>/dev/null || true

    log_info "Installing packages with $PKG_MANAGER..."
    "$PKG_MANAGER" -S --needed --noconfirm "${unique_packages[@]}" || log_warning "Some packages failed to install"

    if [[ ${#aur_packages[@]} -gt 0 ]]; then
      log_info "Installing AUR specific apps..."
      "$PKG_MANAGER" -S --needed --noconfirm "${aur_packages[@]}" || log_warning "AUR apps failed"
    fi
  else
    log_info "Installing via pacman..."
    sudo pacman -S --needed --noconfirm "${unique_packages[@]}" || log_warning "Pacman installation encountered errors"
  fi

  log_success "Package installation completed"
}

create_backup() {
  log_info "Backing up existing configs..."
  local backup_created=false

  for item in "$REPO_DIR/.config"/*; do
    local name=$(basename "$item")
    local target="$CONFIG_DIR/$name"

    if [[ -e "$target" && ! -L "$target" ]]; then
      [[ "$backup_created" == false ]] && mkdir -p "$BACKUP_DIR" && backup_created=true
      mv "$target" "$BACKUP_DIR/"
    fi
  done
  [[ "$backup_created" == true ]] && log_success "Backup saved to $BACKUP_DIR"
}

copy_configs() {
  log_info "Copying configuration files to ~/.config..."
  mkdir -p "$CONFIG_DIR"

  for item in "$REPO_DIR/.config"/*; do
    local name=$(basename "$item")
    log_info "Copying: $name"

    rm -rf "$CONFIG_DIR/$name"

    cp -rf "$item" "$CONFIG_DIR/"
  done

  if [[ -f "$REPO_DIR/.config/.zshrc" ]]; then
    log_info "Copying .zshrc to home directory..."
    cp -f "$REPO_DIR/.config/.zshrc" "$HOME/.zshrc"
  fi

  if [[ -d "$REPO_DIR/assets/wallpaper" ]]; then
    log_info "Copying wallpapers to ~/Pictures/wallpaper..."
    mkdir -p "$HOME/Pictures"
    rm -rf "$HOME/Pictures/wallpaper"
    cp -rf "$REPO_DIR/assets/wallpaper" "$HOME/Pictures/"
  fi

  log_success "All files copied physically. You can safely delete the repo folder after this."
}

setup_cursor() {
  local THEME="Bibata-Modern-Ice"
  local SIZE=24

  log_info "Applying cursor $THEME to Hyprland, GTK, and QT..."

  # 1. HYPRLAND
  if command -v hyprctl &>/dev/null; then
    hyprctl setcursor "$THEME" "$SIZE"
  fi

  # 2. GTK (GSettings & Config Files)
  gsettings set org.gnome.desktop.interface cursor-theme "$THEME"
  gsettings set org.gnome.desktop.interface cursor-size "$SIZE"

  mkdir -p "$HOME/.config/gtk-3.0"
  cat <<EOF >"$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-cursor-theme-name=$THEME
gtk-cursor-theme-size=$SIZE
EOF

  # 3. QT (Environment Variables)
  mkdir -p "$HOME/.config/environment.d"
  echo "XCURSOR_THEME=$THEME" >"$HOME/.config/environment.d/10-cursor.conf"
  echo "XCURSOR_SIZE=$SIZE" >>"$HOME/.config/environment.d/10-cursor.conf"

  # 4. LEGACY/X11 Support
  mkdir -p "$HOME/.icons/default"
  echo -e "[Icon Theme]\nInherits=$THEME" >"$HOME/.icons/default/index.theme"

  log_success "Cursor universal setup complete!"
}

make_scripts_executable() {
  log_info "Optimizing script permissions..."
  find "$REPO_DIR" -name "*.sh" -type f -exec chmod +x {} +
  log_success "Permissions set"
}

setup_shell() {
  log_info "Setting up shell environment..."
  # Use absolute path to bypass 'which' command availability issues
  local zsh_path="/usr/bin/zsh"
  if [[ "$SHELL" != "$zsh_path" ]]; then
    sudo chsh -s "$zsh_path" "$USER"
    log_success "Shell changed to Zsh"
  else
    log_info "Zsh is already default"
  fi
}

create_directories() {
  local dirs=(
    "$HOME/.local/bin" "$HOME/.cache/wal" "$HOME/.cache/rofi-walls"
    "$HOME/Pictures/Screenshots"
  )
  for dir in "${dirs[@]}"; do mkdir -p "$dir"; done
  log_success "Directories prepared"
}
generate_initial_wal() {
  log_info "Initializing wallpaper and colors..."

  local wall_dir="$HOME/Pictures/wallpaper"

  if [ -d "$wall_dir" ] && [ "$(ls -A "$wall_dir")" ]; then
    local random_wall=$(find "$wall_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

    log_info "Selected wallpaper: $(basename "$random_wall")"

    wal -i "$random_wall" -n

    if pgrep -x "Hyprland" >/dev/null; then
      swww-daemon &
      sleep 1
      swww img "$random_wall" --transition-type simple
    fi

    log_success "Theme initialized with random wallpaper."
  else
    log_error "No wallpapers found in $wall_dir. Skipping initialization."
  fi
}
setup_audio() {
  log_info "Enabling Pipewire Audio Services..."
  # Mengaktifkan service pipewire untuk user saat ini
  systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
  log_success "Audio services (Pipewire) enabled."
}

display_summary() {
  echo -e "\n${GREEN}========================================${NC}"
  echo -e "${GREEN}    Installation Completed Successfully!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo -e "${YELLOW}What would you like to do next?${NC}"
  echo -e "1) Reboot (Recommended)"
  echo -e "2) Logout"
  echo -e "3) Exit and reboot later"

  read -rp "Enter choice [1-3]: " choice

  case $choice in
  1)
    log_info "Rebooting system now..."
    sleep 2
    systemctl reboot
    ;;
  2)
    log_info "Logging out..."
    sleep 2
    loginctl terminate-user "$USER"
    ;;
  3)
    echo -e "\n${BLUE}Enjoy your new setup! Don't forget to reboot later.${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}Invalid option. Exiting script...${NC}"
    exit 0
    ;;
  esac
}

main() {
  clear
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}           MyHyperDots Installer        ${NC}"
  echo -e "${BLUE}========================================${NC}\n"

  check_arch
  choose_package_manager
  create_directories
  install_packages
  create_backup
  copy_configs
  setup_cursor
  generate_initial_wal
  make_scripts_executable
  setup_shell
  setup_audio
  display_summary
}

main "$@"
