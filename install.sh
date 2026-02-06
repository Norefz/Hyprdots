#!/bin/bash

# Arch Linux Hyprland Dotfiles Installer
# Author: Expert Linux System Architect
# Description: Robust installer for Hyprland dotfiles with smart dependency management

set -e  # Exit on any error

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
    if ! command -v pacman &> /dev/null; then
        log_error "This script is designed for Arch Linux. pacman not found."
        exit 1
    fi
    log_success "Arch Linux detected"
}

# Let user choose package manager
choose_package_manager() {
    log_info "Choosing AUR package manager..."
    
    local yay_available=false
    local paru_available=false
    
    if command -v yay &> /dev/null; then
        yay_available=true
    fi
    
    if command -v paru &> /dev/null; then
        paru_available=true
    fi
    
    if [[ "$yay_available" == true && "$paru_available" == true ]]; then
        echo -e "${YELLOW}Both yay and paru are available. Please choose your preferred AUR helper:${NC}"
        echo "1) yay (Recommended)"
        echo "2) paru"
        
        while true; do
            read -p "Enter your choice [1-2]: " choice
            case $choice in
                1)
                    PKG_MANAGER="yay"
                    AUR_HELPER_AVAILABLE=true
                    log_success "Selected yay as package manager"
                    break
                    ;;
                2)
                    PKG_MANAGER="paru"
                    AUR_HELPER_AVAILABLE=true
                    log_success "Selected paru as package manager"
                    break
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}"
                    ;;
            esac
        done
    elif [[ "$yay_available" == true ]]; then
        PKG_MANAGER="yay"
        AUR_HELPER_AVAILABLE=true
        log_success "Using yay as package manager"
    elif [[ "$paru_available" == true ]]; then
        PKG_MANAGER="paru"
        AUR_HELPER_AVAILABLE=true
        log_success "Using paru as package manager"
    else
        PKG_MANAGER="pacman"
        AUR_HELPER_AVAILABLE=false
        log_warning "No AUR helper found. AUR packages will be skipped."
        log_info "To install AUR packages later, run:"
        echo "  sudo pacman -S git base-devel"
        echo "  cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    fi
}

# Analyze hyprland.conf for exec commands to identify missing packages
analyze_hyprland_deps() {
    local hyprland_conf="$REPO_DIR/.config/hypr/configs/execs.conf"
    local additional_packages=()
    
    if [[ -f "$hyprland_conf" ]]; then
        # Extract exec and exec-once commands
        local exec_commands=$(grep -E "^(exec|exec-once)" "$hyprland_conf" | sed -E 's/^(exec|exec-once)\s*=\s*//' | sed 's/&$//' | sed 's/~\/\.local\/bin\///g' | awk '{print $1}')
        
        while IFS= read -r cmd; do
            if [[ -n "$cmd" && "$cmd" != "#" ]]; then
                # Map common commands to packages
                case "$cmd" in
                    "swww-daemon") additional_packages+=("swww") ;;
                    "hypridle") additional_packages+=("hypridle") ;;
                    "waybar") additional_packages+=("waybar") ;;
                    "swaync") additional_packages+=("swaync") ;;
                    "fcitx5") additional_packages+=("fcitx5") ;;
                    "eww") additional_packages+=("eww") ;;
                    "dunst") additional_packages+=("dunst") ;;
                    "polkit-gnome-authentication-agent-1") additional_packages+=("polkit-gnome") ;;
                esac
            fi
        done <<< "$exec_commands"
    fi
    
    # Also analyze waybar config for additional dependencies
    local waybar_config="$REPO_DIR/.config/waybar/config.jsonc"
    if [[ -f "$waybar_config" ]]; then
        if grep -q "wireplumber" "$waybar_config"; then
            additional_packages+=("wireplumber")
        fi
        if grep -q "htop" "$waybar_config"; then
            additional_packages+=("htop")
        fi
    fi
    
    echo "${additional_packages[@]}"
}

# Install base packages
install_packages() {
    log_info "Installing required packages..."
    
    # Core Hyprland packages
    local base_packages=(
        "hyprland"
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
    
    log_info "Packages to install: ${unique_packages[*]}"
    
    # Install packages using detected package manager
    if [[ "$AUR_HELPER_AVAILABLE" == true ]]; then
        # Use yay/paru for all packages
        log_info "Installing pacman packages with $PKG_MANAGER..."
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

# Setup Zsh as default shell
setup_zsh() {
    log_info "Setting up Zsh as default shell..."
    
    # Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        log_warning "Zsh is not installed. Installing zsh..."
        sudo pacman -S --needed --noconfirm zsh
    fi
    
    # Get current shell
    local current_shell=$(echo "$SHELL")
    
    # Change default shell to zsh if not already zsh
    if [[ "$current_shell" != */zsh ]]; then
        log_info "Changing default shell from $(basename "$current_shell") to zsh..."
        if command -v zsh &> /dev/null; then
            # Get the full path to zsh without using 'which'
            local zsh_path=""
            if [[ -x "/bin/zsh" ]]; then
                zsh_path="/bin/zsh"
            elif [[ -x "/usr/bin/zsh" ]]; then
                zsh_path="/usr/bin/zsh"
            else
                # Use command -v as fallback
                zsh_path=$(command -v zsh)
            fi
            
            if [[ -n "$zsh_path" ]]; then
                chsh -s "$zsh_path" || {
                    log_error "Failed to change shell. You may need to run 'chsh -s $zsh_path' manually."
                    return 1
                }
                log_success "Default shell changed to zsh"
            else
                log_error "Could not determine zsh path. Cannot change shell."
                return 1
            fi
        else
            log_error "zsh not found in PATH. Cannot change shell."
            return 1
        fi
    else
        log_info "Zsh is already the default shell"
    fi
    
    # Link .zshrc if it exists in .config
    if [[ -f "$REPO_DIR/.config/.zshrc" ]]; then
        log_info "Linking .zshrc configuration..."
        if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
            mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" 2>/dev/null || true
        fi
        ln -sf "$REPO_DIR/.config/.zshrc" "$HOME/.zshrc"
        log_success ".zshrc linked successfully"
    fi
    
    log_success "Zsh setup completed"
}

# Install Python packages
install_python_packages() {
    log_info "Installing Python packages..."
    
    local python_packages=(
        "pywal"
        "python-bidi"
    )
    
    # Check if pip is available
    if command -v pip &> /dev/null; then
        for pkg in "${python_packages[@]}"; do
            log_info "Installing Python package: $pkg"
            pip install --user "$pkg" || log_warning "Failed to install $pkg"
        done
    elif command -v pip3 &> /dev/null; then
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

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    # Create common directories that might be needed
    local directories=(
        "$HOME/.local/share"
        "$HOME/.local/state"
        "$HOME/.cache"
        "$HOME/.cache/wal"
        "$HOME/.cache/rofi-walls"
        "$HOME/.config/hypr"
        "$HOME/.local/bin/scripts"
        "$HOME/Pictures/Screenshots"
        "$HOME/Pictures/wallpaper"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
    
    log_success "Directories created"
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
    create_directories
    install_packages
    install_python_packages
    setup_zsh
    create_backup
    create_symlinks
    make_scripts_executable
    link_scripts_to_bin
    display_summary
}

# Run main function
main "$@"