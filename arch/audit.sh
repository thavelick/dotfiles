#!/bin/bash

# Package categorization script - splits packages into GUI and CLI/system categories
# Based on dependency analysis rather than manual lists

set -euo pipefail

# GUI dependency patterns (version-agnostic)
GUI_PATTERNS=(
    "libx11"
    "libxcb"
    "xorg"
    "gtk"
    "qt"
    "libwayland"
    "wlroots"
    "wayland"
    "cairo"
    "pango"
    "gdk-pixbuf"
    "fontconfig"
    "zenity"
    "lib32-libx"
    "sdl"
    "libgl"
    "glu"
    "libxss"
    "libxtst"
)


# Output files
GUI_PACKAGES_FILE="arch/packages-gui"
CLI_PACKAGES_FILE="arch/packages-cli"
CORE_PACKAGES_FILE="arch/packages-core"

# Arrays to store categorized packages
declare -a gui_packages
declare -a cli_packages
declare -a core_packages

# Load existing core packages (manually curated list)
if [[ -f "$CORE_PACKAGES_FILE" ]]; then
    mapfile -t core_packages < "$CORE_PACKAGES_FILE"
fi

# Function to check if package has GUI dependencies
is_gui_package() {
    local package="$1"
    local deps
    
    # Get package dependencies from installed package (not repository)
    if ! deps=$(pacman -Qi "$package" 2>/dev/null | grep "^Depends On" | cut -d: -f2-); then
        echo "Warning: Could not get dependencies for $package" >&2
        return 1
    fi
    
    # Check each GUI pattern
    for pattern in "${GUI_PATTERNS[@]}"; do
        if echo "$deps" | grep -q "$pattern"; then
            echo "DEBUG: $package -> GUI (matched: $pattern)" >&2
            return 0
        fi
    done
    
    echo "DEBUG: $package -> CLI" >&2
    return 1
}


# Main processing
echo "Categorizing packages based on dependencies..."

# Get all explicitly installed packages
while IFS= read -r line; do
    package=$(echo "$line" | cut -d' ' -f1)
    
    # Skip empty lines
    [[ -n "$package" ]] || continue
    
    # Determine category
    # Check if package is in core list first
    if [[ " ${core_packages[*]} " =~ " $package " ]]; then
        # Skip core packages - they're manually maintained
        continue
    elif is_gui_package "$package"; then
        gui_packages+=("$package")
    else
        cli_packages+=("$package")
    fi
    
done < <(pacman -Qe)

# Sort arrays
mapfile -t gui_packages < <(printf '%s\n' "${gui_packages[@]}" | sort)
mapfile -t cli_packages < <(printf '%s\n' "${cli_packages[@]}" | sort)

# Write output files
echo "Writing $GUI_PACKAGES_FILE (${#gui_packages[@]} packages)..."
printf '%s\n' "${gui_packages[@]}" > "$GUI_PACKAGES_FILE"

echo "Writing $CLI_PACKAGES_FILE (${#cli_packages[@]} packages)..."
printf '%s\n' "${cli_packages[@]}" > "$CLI_PACKAGES_FILE"

echo "Categorization complete!"
echo "Core packages: ${#core_packages[@]} (manually maintained)"
echo "GUI packages: ${#gui_packages[@]}"
echo "CLI packages: ${#cli_packages[@]}"
echo "Total categorized: $((${#gui_packages[@]} + ${#cli_packages[@]}))"
echo "Total with core: $((${#core_packages[@]} + ${#gui_packages[@]} + ${#cli_packages[@]}))"