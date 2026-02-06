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

# Let user choose package manager with better UX
choose_package_manager() {
  log_info "Choosing AUR package manager..."

  local aurList=("yay" "paru" "yay-bin" "paru-bin")
  local yay_available=false
  local paru_available=false

  # Check available helpers
  for helper in "${aurList[@]}"; do
    if command -v "$helper" &>/dev/null; then
      if [[ "$helper" == yay* ]]; then
        yay_available=true
      elif [[ "$helper" == paru* ]]; then
        paru_available=true
      fi
    fi
  done

  # If multiple available, let user choose
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
        log_warning "Skipping AUR packages"
        break
        ;;
      [1-4])
        if [[ $choice -le ${#aurList[@]} ]]; then
          selected_helper="${aurList[$((choice - 1))]}"
          if command -v "$selected_helper" &>/dev/null; then
            PKG_MANAGER="$selected_helper"
            AUR_HELPER_AVAILABLE=true
            log_success "Selected $selected_helper"
            break
          else
            log_warning "$selected_helper not installed"
          fi
        else
          echo -e "${RED}Invalid option. Please enter 0-4.${NC}"
        fi
        ;;
      *)
        echo -e "${RED}Invalid option. Please enter 0-4 or q.${NC}"
        ;;
      esac
    done
  else
    # Install yay if no helpers found
    echo -e "${YELLOW}No AUR helper found. Install yay? (Recommended)${NC}"
    echo "1) Install yay"
    echo "2) Skip AUR packages"

    while true; do
      read -p "Enter option [default: 1] | q to quit: " choice
      choice=${choice:-1}
      case $choice in
      q | Q)
        log_info "Quitting..."
        exit 0
        ;;
      1)
        log_info "Installing yay..."
        if sudo pacman -S --needed --noconfirm git base-devel &&
          cd /tmp &&
          git clone https://aur.archlinux.org/yay.git &&
          cd yay &&
          makepkg -si --noconfirm; then
          PKG_MANAGER="yay"
          AUR_HELPER_AVAILABLE=true
          log_success "yay installed successfully"
        else
          PKG_MANAGER="pacman"
          AUR_HELPER_AVAILABLE=false
          log_warning "yay installation failed, continuing without AUR"
        fi
        break
        ;;
      2)
        PKG_MANAGER="pacman"
        AUR_HELPER_AVAILABLE=false
        log_warning "Skipping AUR packages"
        break
        ;;
      *)
        echo -e "${RED}Invalid option. Please enter 1, 2, or q.${NC}"
        ;;
      esac
    done
  fi
}

# Analyze hyprland.conf for exec commands to identify missing packages
analyze_hyprland_deps() {
  local additional_packages=()
  # Tentukan path config hyprland kamu (sesuaikan jika berbeda)
  local hypr_conf="$REPO_DIR/.config/hypr/hyprland.conf"

  if [[ -f "$hypr_conf" ]]; then
    # Ambil kata pertama setelah 'exec-once =' atau 'exec ='
    local commands=$(grep -E "^exec(-once)?\s*=" "$hypr_conf" | sed -E 's/^exec(-once)?\s*=\s*//' | awk '{print $1}')

    for cmd in $commands; do
      # Bersihkan path jika ada (misal ~/.local/bin/rofi -> rofi)
      cmd=$(basename "$cmd")

      case "$cmd" in
      "rofi") additional_packages+=("rofi-lbonn-wayland-git") ;;
      "ranger") additional_packages+=("ranger") ;;
      "waybar") additional_packages+=("waybar") ;;
      "swaync") additional_packages+=("swaync") ;;
      "nm-applet") additional_packages+=("network-manager-applet") ;;
      "blueman-applet") additional_packages+=("blueman") ;;
      esac
    done
  fi
  echo "${additional_packages[@]}"
}

# Install base packages
install_packages() {
  log_info "Installing required packages..."

  # Core Hyprland packages
  local base_packages=(
    "hyprland"
    "rofi"
    "ranger"
    "hypridle"
    "hyprlock"
    "waybar"
    "swaync"
    "kitty"
    "swww"
    "brightnessctl"
    "playerctl"
    "grim"
    "slurp"
    "jq"
    "ttf-jetbrains-mono-nerd"
    "papirus-icon-theme"
    "network-manager-applet"
    "polkit-gnome"
    "dunst"
    "fcitx5"
    "cava"
    "ranger"
    "fastfetch"
    "starship"
    "eww"
    "qt6ct"
    "thunar"
    "wofi"
    "htop"
    "wireplumber"
    "wl-clipboard"
    "wlogout"
    "libnotify"
    "python3"
    "bc"
    "wget"
    "atool"
    "imagemagick"
    "zsh"
    "blueman"
    "nm-connection-editor"
    "ttf-firacode-nerd"
    "which"
  )

  # AUR packages (need yay/paru)
  local aur_packages=(
    "rofi-lbonn-wayland-git"
    "zen-browser"
    "vesktop"
    "whatsdesk"
    "pywal-discord"
    "miku-cursor-theme"
  )

  # Additional packages from hyprland analysis
  log_info "Analyzing hyprland configuration for dependencies..."
  local additional_packages=($(analyze_hyprland_deps))

  # Combine packages and remove duplicates
  local all_packages=("${base_packages[@]}" "${additional_packages[@]}")
  local unique_packages=($(printf "%s\n" "${all_packages[@]}" | sort -u))

  log_info "Found ${#unique_packages[@]} packages to install"

  # Install packages using detected package manager
  if [[ "$AUR_HELPER_AVAILABLE" == true ]]; then
    # Use yay/paru for all packages
    log_info "Installing ${#unique_packages[@]} packages with $PKG_MANAGER..."
    echo "Packages: ${unique_packages[*]}"
    "$PKG_MANAGER" -S --needed --noconfirm "${unique_packages[@]}" || {
      log_warning "Some packages failed to install, continuing..."
    }

    if [[ ${#aur_packages[@]} -gt 0 ]]; then
      log_info "Installing AUR packages with $PKG_MANAGER..."
      "$PKG_MANAGER" -S --needed --noconfirm "${aur_packages[@]}" || {
        log_warning "Some AUR packages failed to install, continuing..."
      }
    fi
  else
    # Only install pacman packages, skip AUR
    local pacman_packages=()

    for pkg in "${unique_packages[@]}"; do
      pacman_packages+=("$pkg")
    done

    if [[ ${#pacman_packages[@]} -gt 0 ]]; then
      log_info "Installing pacman packages: ${pacman_packages[*]}"
      sudo pacman -S --needed --noconfirm "${pacman_packages[@]}" || {
        log_warning "Some packages failed to install, continuing..."
      }
    fi

    if [[ ${#aur_packages[@]} -gt 0 ]]; then
      log_warning "Skipping AUR packages (no AUR helper available):"
      for aur_pkg in "${aur_packages[@]}"; do
        echo "  • $aur_pkg"
      done
      log_info "Install yay or paru later to install these packages"
    fi
  fi

  log_success "Package installation completed"
}

# Create backup of existing config files
create_backup() {
  log_info "Checking for existing configuration files..."

  local backup_created=false

  # Check each config folder that will be linked
  for config_folder in "$REPO_DIR/.config"/*; do
    if [[ -d "$config_folder" ]]; then
      local folder_name=$(basename "$config_folder")
      local target_path="$CONFIG_DIR/$folder_name"

      if [[ -e "$target_path" && ! -L "$target_path" ]]; then
        if [[ "$backup_created" == false ]]; then
          mkdir -p "$BACKUP_DIR"
          backup_created=true
          log_warning "Creating backup at $BACKUP_DIR"
        fi

        log_info "Backing up $folder_name"
        mv "$target_path" "$BACKUP_DIR/"
      fi
    fi
  done

  # Check individual config files (like .zshrc)
  for config_file in "$REPO_DIR/.config"/*; do
    if [[ -f "$config_file" ]]; then
      local file_name=$(basename "$config_file")

      # Handle .zshrc in home directory
      if [[ "$file_name" == ".zshrc" ]]; then
        local target_path="$HOME/.zshrc"
        if [[ -e "$target_path" && ! -L "$target_path" ]]; then
          if [[ "$backup_created" == false ]]; then
            mkdir -p "$BACKUP_DIR"
            backup_created=true
            log_warning "Creating backup at $BACKUP_DIR"
          fi

          log_info "Backing up .zshrc"
          mv "$target_path" "$BACKUP_DIR/"
        fi
      fi
    fi
  done

  if [[ "$backup_created" == true ]]; then
    log_success "Backup completed"
  else
    log_info "No existing configs to backup"
  fi
}

# Create symbolic links for config folders
create_symlinks() {
  log_info "Creating symbolic links for configuration files..."

  # Ensure ~/.config exists
  mkdir -p "$CONFIG_DIR"

  # Link all config folders
  for config_folder in "$REPO_DIR/.config"/*; do
    if [[ -d "$config_folder" ]]; then
      local folder_name=$(basename "$config_folder")
      local target_path="$CONFIG_DIR/$folder_name"

      log_info "Linking $folder_name"
      ln -sf "$config_folder" "$target_path"
    fi
  done

  # Link individual config files (like .zshrc if it's in .config)
  for config_file in "$REPO_DIR/.config"/*; do
    if [[ -f "$config_file" ]]; then
      local file_name=$(basename "$config_file")
      local target_path="$CONFIG_DIR/$file_name"

      # Skip if it's a backup or temporary file
      if [[ "$file_name" == *.bak || "$file_name" == *~ ]]; then
        continue
      fi

      log_info "Linking config file: $file_name"
      ln -sf "$config_file" "$target_path"
    fi
  done

  log_success "Configuration symlinks created"
}

# Make all shell scripts executable
make_scripts_executable() {
  log_info "Making all shell scripts executable..."

  # Find all .sh files in the repository and make them executable
  find "$REPO_DIR" -name "*.sh" -type f -print0 | while IFS= read -r -d $'\0' script; do
    log_info "Making executable: $(basename "$script")"
    chmod +x "$script"
  done

  log_success "All shell scripts are now executable"
}

# Let user choose and setup shell
setup_shell() {
  log_info "Setting up shell..."

  local shlList=("zsh" "fish" "bash")

  echo -e "${YELLOW}Choose your default shell:${NC}"
  for i in "${!shlList[@]}"; do
    if [[ "$SHELL" == */${shlList[$i]} ]]; then
      echo "$((i + 1))) ${shlList[$i]} (current) ✓"
    else
      echo "$((i + 1))) ${shlList[$i]}"
    fi
  done

  while true; do
    read -p "Enter option [default: 1] | q to quit: " choice
    choice=${choice:-1}
    case $choice in
    q | Q)
      log_info "Skipping shell setup..."
      return 0
      ;;
    [1-3])
      if [[ $choice -le ${#shlList[@]} ]]; then
        selected_shell="${shlList[$((choice - 1))]}"
        break
      else
        echo -e "${RED}Invalid option. Please enter 1-3.${NC}"
      fi
      ;;
    *)
      echo -e "${RED}Invalid option. Please enter 1-3 or q.${NC}"
      ;;
    esac
  done

  # Install selected shell if not present
  if ! command -v "$selected_shell" &>/dev/null; then
    log_info "Installing $selected_shell..."
    if sudo pacman -S --needed --noconfirm "$selected_shell"; then
      log_success "$selected_shell installed successfully"
    else
      log_warning "Failed to install $selected_shell"
      return 1
    fi
  fi

  # Change default shell if different from current
  local current_shell=$(basename "$SHELL")
  if [[ "$current_shell" != "$selected_shell" ]]; then
    log_info "Changing default shell from $current_shell to $selected_shell..."

    # Get full path without using which
    local shell_path=""
    if [[ -x "/bin/$selected_shell" ]]; then
      shell_path="/bin/$selected_shell"
    elif [[ -x "/usr/bin/$selected_shell" ]]; then
      shell_path="/usr/bin/$selected_shell"
    else
      shell_path=$(command -v "$selected_shell")
    fi

    if [[ -n "$shell_path" ]]; then
      if chsh -s "$shell_path"; then
        log_success "Default shell changed to $selected_shell"
      else
        log_warning "Failed to change shell. You may need to run 'chsh -s $shell_path' manually."
      fi
    else
      log_error "Could not determine $selected_shell path."
      return 1
    fi
  else
    log_info "$selected_shell is already the default shell"
  fi

  # Link shell config if it exists
  local config_file=".${selected_shell}rc"
  if [[ -f "$REPO_DIR/.config/$config_file" ]]; then
    log_info "Linking $config_file..."
    if [[ -f "$HOME/$config_file" && ! -L "$HOME/$config_file" ]]; then
      mkdir -p "$BACKUP_DIR"
      mv "$HOME/$config_file" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    ln -sf "$REPO_DIR/.config/$config_file" "$HOME/$config_file"
    log_success "$config_file linked successfully"
  fi

  log_success "Shell setup completed"
}

# Install Python packages
install_python_packages() {
  log_info "Installing Python packages..."

  local python_packages=(
    "pywal"
    "python-bidi"
  )

  # Check if pip is available
  if command -v pip &>/dev/null; then
    for pkg in "${python_packages[@]}"; do
      log_info "Installing Python package: $pkg"
      pip install --user "$pkg" || log_warning "Failed to install $pkg"
    done
  elif command -v pip3 &>/dev/null; then
    for pkg in "${python_packages[@]}"; do
      log_info "Installing Python package: $pkg"
      pip3 install --user "$pkg" || log_warning "Failed to install $pkg"
    done
  else
    log_warning "pip not found, skipping Python packages installation"
  fi

  log_success "Python packages installation completed"
}

# Link scripts to ~/.local/bin/
link_scripts_to_bin() {
  log_info "Linking scripts to ~/.local/bin/..."

  # Ensure ~/.local/bin exists
  mkdir -p "$LOCAL_BIN_DIR"

  # Link all files from scripts/ folder
  if [[ -d "$REPO_DIR/scripts" ]]; then
    for script_file in "$REPO_DIR/scripts"/*; do
      if [[ -f "$script_file" ]]; then
        local script_name=$(basename "$script_file")
        local target_path="$LOCAL_BIN_DIR/$script_name"

        log_info "Linking script: $script_name"
        ln -sf "$script_file" "$target_path"
      fi
    done
  fi

  # Also link scripts from .config/hypr/Scripts/
  if [[ -d "$REPO_DIR/.config/hypr/Scripts" ]]; then
    for script_file in "$REPO_DIR/.config/hypr/Scripts"/*; do
      if [[ -f "$script_file" ]]; then
        local script_name=$(basename "$script_file")
        local target_path="$LOCAL_BIN_DIR/$script_name"

        log_info "Linking Hyprland script: $script_name"
        ln -sf "$script_file" "$target_path"
      fi
    done
  fi

  # Link other scattered scripts (rofi, etc.)
  find "$REPO_DIR/.config" -name "*.sh" -type f -print0 | while IFS= read -r -d $'\0' script; do
    local script_name=$(basename "$script")
    local target_path="$LOCAL_BIN_DIR/$script_name"

    log_info "Linking config script: $script_name"
    ln -sf "$script" "$target_path"
  done

  log_success "Scripts linked to ~/.local/bin/"
}

# Create necessary directories with better organization
create_directories() {
  log_info "Creating necessary directories..."

  # Create log directory first
  mkdir -p "$HOME/.local/share/logs"

  # Create common directories that might be needed
  local directories=(
    "$HOME/.local/share"
    "$HOME/.local/state"
    "$HOME/.local/bin"
    "$HOME/.local/bin/scripts"
    "$HOME/.cache"
    "$HOME/.cache/wal"
    "$HOME/.cache/rofi-walls"
    "$HOME/.cache/swww"
    "$HOME/Pictures/Screenshots"
    "$HOME/Pictures/wallpaper"
    "$HOME/Videos"
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Templates"
    "$HOME/Public"
    "$HOME/Music"
  )

  local created_count=0
  for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir"
      ((created_count++))
    fi
  done

  if [[ $created_count -gt 0 ]]; then
    log_success "Created $created_count directories"
  else
    log_info "All directories already exist"
  fi
}

# Display installation summary
display_summary() {
  echo
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}    Installation Completed!          ${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo
  echo -e "${BLUE}What was installed:${NC}"
  echo "  • Hyprland and essential packages"
  echo "  • Configuration files linked to ~/.config/"
  echo "  • Scripts linked to ~/.local/bin/"
  echo "  • All shell scripts made executable"
  echo
  if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${YELLOW}Backup created at:${NC}"
    echo "  • $BACKUP_DIR"
    echo
  fi
  echo -e "${BLUE}Next steps:${NC}"
  echo "  1. Reboot or relogin to apply changes"
  echo "  2. Run 'hyprland' to start your session"
  echo "  3. Customize your setup as needed"
  echo
  echo -e "${GREEN}Enjoy your new Hyprland setup! 🚀${NC}"
  echo
}

# Main installation function
main() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}         MyHyperDots                  ${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo

  # Run installation steps
  check_arch
  choose_package_manager
  setup_shell
  create_directories
  install_packages
  install_python_packages
  create_backup
  create_symlinks
  make_scripts_executable
  link_scripts_to_bin
  display_summary
}

# Run main function
main "$@"

