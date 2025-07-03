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
)

# Manual overrides (use sparingly, with justification)
# Format: package_name:category:reason
MANUAL_OVERRIDES=(
    # Add here only if dependency detection fails
    # Example: "some-package:gui:uses GUI but deps not detected"
)

# Output files
GUI_PACKAGES_FILE="arch/packages-gui"
CLI_PACKAGES_FILE="arch/packages-cli"

# Arrays to store categorized packages
declare -a gui_packages
declare -a cli_packages

# Function to check if package has GUI dependencies
is_gui_package() {
    local package="$1"
    local deps
    
    # Get package dependencies
    if ! deps=$(pacman -Si "$package" 2>/dev/null | grep "^Depends On" | cut -d: -f2-); then
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

# Function to apply manual overrides
apply_manual_overrides() {
    local package="$1"
    local detected_category="$2"
    
    for override in "${MANUAL_OVERRIDES[@]}"; do
        local pkg_name
        local category
        local reason
        pkg_name=$(echo "$override" | cut -d: -f1)
        category=$(echo "$override" | cut -d: -f2)
        reason=$(echo "$override" | cut -d: -f3)
        
        if [[ "$package" == "$pkg_name" ]]; then
            if [[ "$detected_category" != "$category" ]]; then
                echo "INFO: Manual override for $package: $detected_category -> $category ($reason)" >&2
            else
                echo "WARNING: Manual override for $package may be outdated (detection now works)" >&2
            fi
            echo "$category"
            return 0
        fi
    done
    
    echo "$detected_category"
}

# Main processing
echo "Categorizing packages based on dependencies..."

# Get all explicitly installed packages
while IFS= read -r line; do
    package=$(echo "$line" | cut -d' ' -f1)
    
    # Skip empty lines
    [[ -n "$package" ]] || continue
    
    # Determine category
    if is_gui_package "$package"; then
        detected_category="gui"
    else
        detected_category="cli"
    fi
    
    # Apply manual overrides if any
    final_category=$(apply_manual_overrides "$package" "$detected_category")
    
    # Add to appropriate array
    if [[ "$final_category" == "gui" ]]; then
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
echo "GUI packages: ${#gui_packages[@]}"
echo "CLI packages: ${#cli_packages[@]}"
echo "Total: $((${#gui_packages[@]} + ${#cli_packages[@]}))"