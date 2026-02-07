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
    "fcitx5" "cava" "ranger" "fastfetch" "starship" "eww" "qt6ct"
    "thunar" "rofi" "htop" "wireplumber" "wl-clipboard" "wlogout"
    "libnotify" "python3" "bc" "wget" "atool" "imagemagick" "zsh"
    "blueman" "nvim" "exa" "pokemon-colorscripts-git" "sl" "cmatrix" "nm-connection-editor" "ttf-firacode-nerd" "which"
  )

  local aur_packages=(
    "rofi-lbonn-wayland-git"
    "fzf"
    "python-pywal16"
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

create_symlinks() {
  log_info "Creating symlinks..."
  mkdir -p "$CONFIG_DIR"
  for item in "$REPO_DIR/.config"/*; do
    local name=$(basename "$item")
    local target="$CONFIG_DIR/$name"

    log_info "Linking: $name"
    ln -sf "$item" "$target"
  done
  if [[ -d "$REPO_DIR/assets/wallpaper" ]]; then
    log_info "Linking wallpapers from assets..."
    mkdir -p "$HOME/Pictures"
    ln -sf "$REPO_DIR/assets/wallpaper" "$HOME/Pictures/wallpaper"
  fi
  # Special case for .zshrc if it exists in .config
  [[ -f "$REPO_DIR/.config/.zshrc" ]] && ln -sf "$REPO_DIR/.config/.zshrc" "$HOME/.zshrc"
  [[ -f "$REPO_DIR/.config/.starship.toml" ]] && ln -sf "$REPO_DIR/.config/.zshrc" "$HOME/.zshrc"
  log_success "Symlinks created"
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
    "$HOME/Pictures/Screenshots" "$HOME/Pictures/wallpaper"
  )
  for dir in "${dirs[@]}"; do mkdir -p "$dir"; done
  log_success "Directories prepared"
}

display_summary() {
  echo -e "\n${GREEN}========================================${NC}"
  echo -e "${GREEN}    Installation Completed Successfully!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo -e "1. Reboot your system\n2. Log into Hyprland\n3. Enjoy!\n"
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
  create_symlinks
  make_scripts_executable
  setup_shell
  display_summary
}

main "$@"
