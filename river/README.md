# River Window Manager Configuration

This directory contains the configuration for the River Wayland compositor.

## Keybinding Reference

**Modifier Key:** `Alt` (Mod1)

### Application Launchers

| Keybinding | Action |
|------------|--------|
| `Alt + Shift + Enter` | Launch terminal (foot) |
| `Alt + P` | Application launcher |
| `Alt + E` | Emoji picker |
| `Alt + D` | Document picker |
| `Alt + H` | Show this help/keybindings |

### Window Management

| Keybinding | Action |
|------------|--------|
| `Alt + Q` | Close focused window |
| `Alt + Shift + E` | Exit River |
| `Alt + J` | Focus next window |
| `Alt + K` | Focus previous window |
| `Alt + Shift + J` | Swap with next window |
| `Alt + Shift + K` | Swap with previous window |
| `Alt + Enter` | Move window to top of stack |
| `Alt + Space` | Toggle floating mode |
| `Alt + F` | Toggle fullscreen |

### Layout & Tiling

| Keybinding | Action |
|------------|--------|
| `Alt + Up` | Main area at top |
| `Alt + Right` | Main area on right |
| `Alt + Down` | Main area at bottom |
| `Alt + Left` | Main area on left |

### Monitor/Output Control

| Keybinding | Action |
|------------|--------|
| `Alt + Period (.)` | Focus next monitor |
| `Alt + Comma (,)` | Focus previous monitor |
| `Alt + Shift + Period` | Move window to next monitor |
| `Alt + Shift + Comma` | Move window to previous monitor |
| `Alt + O` | Focus next monitor (alternate) |
| `Alt + Shift + O` | Move window to next monitor (alternate) |

### Tags (Workspaces)

| Keybinding | Action |
|------------|--------|
| `Alt + 1-9` | Switch to tag 1-9 |
| `Alt + Shift + 1-9` | Move window to tag 1-9 |
| `Alt + Ctrl + 1-9` | Toggle tag visibility |
| `Alt + 0` | Show all tags |

### System Controls

#### Media Keys (Surface Pro/Laptop)
- **Volume Up/Down/Mute** - Hardware media keys
- **Brightness Up/Down** - Hardware function keys
- **Play/Pause/Next/Previous** - Hardware media keys

#### MNT Reform Controls
| Keybinding | Action |
|------------|--------|
| `Alt + F1` | Brightness up |
| `Alt + F2` | Brightness down |
| `Alt + F3` | Play/pause |
| `Alt + F4` | Mute toggle |
| `Alt + F5` | Volume down |
| `Alt + F6` | Volume up |

### Security

| Keybinding | Action |
|------------|--------|
| `Alt + L` | Lock screen |

### Special Modes

| Keybinding | Action |
|------------|--------|
| `Alt + F11` | Enter passthrough mode (for nested compositors) |
| `Alt + F11` | Exit passthrough mode (when in passthrough) |

### Mouse Controls

| Keybinding | Action |
|------------|--------|
| `Alt + Left Click + Drag` | Move window |
| `Alt + Right Click + Drag` | Resize window |

## Configuration Files

- `init` - Main River configuration script
- `launcher.sh` - Application launcher script
- `document_launcher.sh` - Document picker script  
- `emoji.sh` - Emoji picker script
- `background.sh` - Wallpaper setup
- `setup.sh` - River installation and setup
- `keybindings` - Automated keybinding parser (for comparison)

## Multi-Monitor Setup

The configuration automatically detects and configures multiple monitors with appropriate scaling. External monitors are positioned and scaled based on the setup detected at startup.

## Background Services

River automatically starts these services:
- **Waybar** - Status bar
- **Swayidle** - Idle management and auto-lock
- **Udiskie** - USB device mounting