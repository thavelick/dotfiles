#!/bin/bash
# Setup script for darkman theme switching integration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DARK_MODE_DIR="${HOME}/.local/share/dark-mode.d"
LIGHT_MODE_DIR="${HOME}/.local/share/light-mode.d"

echo "Setting up darkman theme integration..."

# Create darkman directories if they don't exist
mkdir -p "$DARK_MODE_DIR" "$LIGHT_MODE_DIR"

# Function to create symlinks for scripts
link_scripts() {
    local source_dir=$1
    local target_dir=$2
    local mode=$3

    echo "Linking $mode mode scripts..."

    for script in "$source_dir"/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            target_path="$target_dir/$script_name"

            # Remove existing symlink or file
            [[ -L "$target_path" || -f "$target_path" ]] && rm "$target_path"

            # Create symlink
            ln -s "$script" "$target_path"
            chmod +x "$script"
            echo "  ✓ Linked $script_name"
        fi
    done
}

# Link dark mode scripts
link_scripts "$SCRIPT_DIR/dark-mode.d" "$DARK_MODE_DIR" "dark"

# Link light mode scripts
link_scripts "$SCRIPT_DIR/light-mode.d" "$LIGHT_MODE_DIR" "light"

# Make theme functions executable
chmod +x "$SCRIPT_DIR/theme-functions.sh"

echo "✓ All scripts linked successfully"

# Check if darkman is installed
if ! command -v darkman >/dev/null 2>&1; then
    echo "⚠️  Warning: darkman is not installed"
    echo "   Install it with: pacman -S darkman"
    echo "   Or run this from your dotfiles root: pacman -S --needed - < arch/packages-cli"
    exit 1
fi

# Enable and start darkman service
echo "Enabling darkman service..."
if systemctl --user enable --now darkman.service; then
    echo "✓ Darkman service enabled and started"
else
    echo "⚠️  Warning: Failed to enable darkman service"
    echo "   You may need to enable it manually: systemctl --user enable --now darkman.service"
fi

# Check service status
echo ""
echo "Darkman service status:"
systemctl --user status darkman.service --no-pager -l

echo ""
echo "🎉 Darkman setup complete!"
echo ""
echo "Commands:"
echo "  darkman get           - Check current mode"
echo "  darkman set dark      - Switch to dark mode"
echo "  darkman set light     - Switch to light mode"
echo "  darkman toggle        - Toggle between modes"
echo ""
echo "The service will automatically switch themes at sunrise/sunset."
echo "Claude terminals will show notifications when theme changes - restart Claude to see the new theme."