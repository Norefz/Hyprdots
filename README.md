<h1 align="center"> My Hyprdots</h1>

## Priview
https://github.com/user-attachments/assets/0a31ff22-1430-4d8b-9d87-303e9b43fdbf




## Waybar 
![waybar](https://github.com/user-attachments/assets/59197883-6ce6-4acf-98d5-80b7889149b8)

## Kitty Terminal 
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d9408847-046d-4392-95b3-b42a5d92f9d3" />

## Ranger
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/863e43e4-6359-494f-8b03-197896d9e53a" />


## Rofi Menu
![rofi](https://github.com/user-attachments/assets/47f3760b-0d47-4eaf-a09a-50d895f53218)

## Rofi WallChanger
![rofi wallpaper changer](https://github.com/user-attachments/assets/91dda0d1-453b-4464-8975-2ad1a35ff89b)

## Ranger
![ranger](https://github.com/user-attachments/assets/265945a7-197f-4073-b161-3c49ce6f6d78)

## Wlogout
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9dde8425-de6b-4271-996f-186610fea42a" />

## SwayNotif
<img width="793" height="470" alt="image" src="https://github.com/user-attachments/assets/69efa28d-ce42-4f2c-b434-991836866d24" />

## SwayNc
<img width="448" height="1012" alt="image" src="https://github.com/user-attachments/assets/29daf45d-21f4-41db-afef-2efeca8f3143" />

## HyprLock
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/8b437af2-2256-41e3-a55c-1d3100c23aae" />


### 📦 Programs Included

- **Window Manager**: Hyprland (Tiling)
- **Status Bar**: Waybar
- **Notification Manager**: Swaync
- **Color Picker**: pywal
- **Wallpaper Utility**: rofi
- **Screenshot Utility**: grim + slurp
- **App Launcher**: Rofi
- **Terminal Emulator**: kitty
- **Shell**: Zsh
- **File Manager**: Thunar
- **Terminal File**: Ranger
- **Logout**: wlogout
- **Lock Session**: hyprlock
- **Media Controls**: playerctl
- **Brightness Control**: brightnessctl
- **Audio Management**: pamixer, pipewire
- **Network Management**: NetworkManager (nmcli), iwd (iNet Wireless Daemon)

## 

---

## ⚠️ Important Notice (Read Before Running Setup)

> ### **Warning:**
>
> This setup script will **move your existing config files** (e.g., for Waybar, Kitty, Hyprland, etc.) to a backup folder at `~/.config_backup`. Then, it will copy the new configs from this repo into your `~/.config` directory.
>
> ### What this means:
>
> - Your current setup will be **replaced**.
> - If you have customizations you care about, **back them up manually** or review the script before running.
> - Fonts and themes will be installed system-wide in your `~/.local/share/fonts` directory.

---

---

## 🛠️ Installation Steps

1. **Clone the repository** to your home directory like `~` or `/home/username` :

   ```sh
   git clone https://github.com/Norefz/Hyprdots.git
   ```

2. **Navigate to the cloned directory**:

   ```sh
   cd ~/Hyprdots
   ```

3. **Run the setup script**:

   ```sh
   bash ./install.sh
   ```




## Keybindings

## ⌨️ Keybindings

These dotfiles use **SUPER** (Windows Key) as the main modifier (`$mainMod`).

### 🖥️ System & Management
| Shortcut | Action |
| :--- | :--- |
| <kbd>⌘</kbd> + <kbd>D</kbd> | Launch App Launcher (Rofi) |
| <kbd>⌘</kbd> + <kbd>W</kbd> | Open Wallpaper Picker |
| <kbd>⌘</kbd> + <kbd>R</kbd> | Randomize Wallpaper & Colors (Pywal) |
| <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | Restart Waybar & Reload Hyprland |
| <kbd>⌘</kbd> + <kbd>M</kbd> | Exit Hyprland Session |

### 🚀 Applications
| Shortcut | Action |
| :--- | :--- |
| <kbd>⌘</kbd> + <kbd>Return</kbd> | Open Terminal (Kitty) |
| <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd> | Open Floating Terminal |
| <kbd>⌘</kbd> + <kbd>G</kbd> | Open Web Browser (Zen Browser) |
| <kbd>⌘</kbd> + <kbd>E</kbd> | Open File Manager (Thunar) |

### 🪟 Window Management
| Shortcut | Action |
| :--- | :--- |
| <kbd>⌘</kbd> + <kbd>X</kbd> | Kill Active Window |
| <kbd>⌘</kbd> + <kbd>F</kbd> | Toggle Fullscreen |
| <kbd>⌘</kbd> + <kbd>T</kbd> | Toggle Floating Mode |
| <kbd>⌘</kbd> + <kbd>P</kbd> | Toggle Pseudo-tiling |
| <kbd>⌘</kbd> + <kbd>V</kbd> | Toggle Split (Dwindle) |
| <kbd>⌘</kbd> + <kbd>H</kbd> <kbd>J</kbd> <kbd>K</kbd> <kbd>L</kbd> | Move Focus (Left/Down/Up/Right) |
| <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> <kbd>J</kbd> <kbd>K</kbd> <kbd>L</kbd> | Swap Window Position |

### 📑 Workspaces
| Shortcut | Action |
| :--- | :--- |
| <kbd>⌘</kbd> + <kbd>1-0</kbd> | Switch to Workspace 1-10 |
| <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>1-0</kbd> | Move Window to Workspace 1-10 |
| <kbd>⌘</kbd> + <kbd>S</kbd> | Toggle Special Workspace (Scratchpad) |
| <kbd>⌘</kbd> + <kbd>[</kbd> or <kbd>]</kbd> | Cycle Through Workspaces |

### 📸 Screenshots & Media
| Shortcut | Action |
| :--- | :--- |
| <kbd>Print</kbd> | Fullscreen Screenshot (Save & Copy) |
| <kbd>⌘</kbd> + <kbd>Print</kbd> | Screenshot Active Window |
| <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>Print</kbd> | Screenshot Selected Region |
| <kbd>XF86 Volume</kbd> | Adjust Volume (Up/Down/Mute) |
| <kbd>XF86 Brightness</kbd> | Adjust Screen Brightness |
### Workspace Management
