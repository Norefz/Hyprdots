<h1 align="center">🫟 Hyprdots</h1>



## 🚀 Quick Installation Guide

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
- **Media Controls**: playerctl
- **Power Management**: acpi
- **Brightness Control**: brightnessctl
- **Audio Management**: pamixer, popewire
- **Network Management**: NetworkManager (nmcli), iwd (iNet Wireless Daemon)


## 🛠️ Installation Steps

1. **Clone the repository** to your home directory like `~` or `/home/username` :

   ```sh
   git clone https://github.com/ad1822/hyprdots ~/hyprdots
   ```

2. **Navigate to the cloned directory**:

   ```sh
   cd ~/hyprdots
   ```

3. **Run the setup script**:

   ```sh
   bash ./install.sh
   ```


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

## My Workflow

>- You can change this behavior in your Hyprland input configuration if you prefer the default key layout.

## Keybindings

| Shortcut                       | Action                                                      |
| ------------------------------ | ----------------------------------------------------------- |
| **`⌘ + T`**             | Open terminal                                               |
| **`⌘ + B`**             | Launch browser                                              |
| **`⌘ + W`**             | Close active window                                         |
| **`⌘ + V`**             | Toggle floating mode                                        |
| **`⌘ + F`**             | Enable fullscreen (mode 1)                                  |
| **`⌘ + G`**             | Disable fullscreen (mode 0)                                 |
| **`⌘ + N`**             | Launch floating Neovim Anywhere window                      |
| **`⌘ + O`**             | Launch Obsidian                                             |
| **`⌘ + E`**             | Open file manager in terminal                               |
| **`⌘ + P`**             | Open Rofi power menu (Rofi)                                        |
| **`⌘ + Space`**         | Launch Rofi app launcher (Rofi)                                   |
| **`⌘ + Shift + R`**     | Open wallpaper selector and reload Hyprpaper                |
| **`⌘ + Shift + S`**     | Take area screenshot using Grim & Slurp (copy to clipboard) |
| **`Print`**                    | Take area screenshot and save with Grimblast                |
| **`Alt + Shift + S`**          | Run custom screenshot script                                |
| **`Alt + Shift + W`**          | Restart Waybar                                              |
| **`Ctrl + Shift + Tab`**       | Open task manager in terminal                               |
| **`⌘ + C`**             | Launch color picker                                         |
| **`⌘ + I`**             | Change wallpaper and reload Hyprpaper                       |
| **`⌘ + M`**             | Launch Rofi clipboard manager (Rofi)                              |
| **`⌘ + Shift + L`**     | Lock screen using Hyprlock                                  |
| **`⌘ + A`**             | Launch Rofi Wi-Fi selector (Rofi)                                  |
| **`Alt + Tab`**                | Cycle to next window                                        |
| **`Alt + Shift + Tab`**        | Cycle to previous window                                    |
| **`⌘ + Tab`**           | Bring active window to top                                  |
| **`⌘ + H / J / K / L`** | Move focus (left / down / up / right)                       |

### Workspace Management

| Shortcut                       | Action                                          |
| ------------------------------ | ----------------------------------------------- |
| **`⌘ + 1–6`**           | Switch to workspace 1–6                         |
| **`⌘ + 0 / 9 / 8 / 7`** | Alternate workspace mapping (custom preference) |
| **`⌘ + Shift + [1–0]`** | Move active window to workspace 1–10            |

---

## Tmux Workflow

> **Prefix key:** `Ctrl + A`
> To enable these shortcuts, clone my **dotsh** repository containing all the custom scripts:

```bash
git clone https://github.com/ad1822/dotsh.git ~/work/main/dotsh
```

After cloning, update the paths in your Tmux configuration if your directory structure differs.

| Shortcut       | Description                                                                    |
| -------------- | ------------------------------------------------------------------------------ |
| **Prefix + i** | Launch *fzf-based cheatsheat* (`~/work/main/dotsh/fzf/ch`)                |
| **Prefix + t** | Open *fzf Tmux session switcher* (`~/work/main/dotsh/fzf/tmux-session`)        |
| **Prefix + d** | Edit dotfiles via *fzf-based selector* (`~/work/main/dotsh/fzf/edit-dotfiles`) |
| **Prefix + m** | Open *[mpterm](https://github.com/ad1822/mpterm)* — a minimal music player terminal                                r

---
