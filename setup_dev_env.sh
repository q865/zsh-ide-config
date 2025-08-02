#!/bin/bash
#
# This script sets up a development environment using Kitty, Zellij, and Zsh.
#
# It will:
# 1. Create configuration directories for Kitty and Zellij.
# 2. Download the Catppuccin theme for Kitty.
# 3. Create a Kitty configuration file with a Nerd Font.
# 4. Create a Zellij configuration file with the Catppuccin theme.
# 5. Create a Zellij layout for a standard development setup.
# 6. Add aliases to your .zshrc for easy access.
#
# Prerequisites:
# - A Nerd Font installed (e.g., FiraCode Nerd Font).
# - `curl` for downloading themes.
# - `eza` for better `ls` (optional, but recommended for the alias).
# - `zellij` and `kitty` installed.

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting development environment setup..."

# --- Create Directories ---
echo "🔧 Creating configuration directories..."
mkdir -p ~/.config/kitty
mkdir -p ~/.config/zellij/layouts

# --- Kitty Setup ---
echo "🎨 Setting up Kitty..."
echo "    - Downloading Catppuccin Mocha theme..."
curl -s -o ~/.config/kitty/catppuccin-mocha.conf https://raw.githubusercontent.com/catppuccin/kitty/main/mocha.conf

echo "    - Creating kitty.conf..."
cat <<EOF > ~/.config/kitty/kitty.conf
# Include the Catppuccin Mocha theme
@include "catppuccin-mocha.conf"

# Set the font to a Nerd Font for icons
# IMPORTANT: Make sure you have "FiraCode Nerd Font Mono" installed!
font_family      FiraCode Nerd Font Mono
bold_font        auto
italic_font      auto
bold_italic_font auto

# Add some padding for a cleaner look
window_padding_width 10
EOF

# --- Zellij Setup ---
echo "🔌 Setting up Zellij..."
echo "    - Creating config.kdl..."
cat <<EOF > ~/.config/zellij/config.kdl
// Use the Catppuccin theme to match Kitty
theme "catppuccin-mocha"

// A cleaner UI without extra pane separators
simplified_ui true

// Default layout for sessions started without a specific layout
default_layout "compact"

// Disable Zellij's mouse mode to allow native terminal text selection
mouse_mode false
copy_on_select false

// Basic vim-like navigation
keybinds {
    normal {
        // Use Alt + hjkl to move between panes
        bind "Alt h" { MoveFocus "Left"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        bind "Alt l" { MoveFocus "Right"; }
    }
}
EOF

echo "    - Creating dev-setup.kdl layout..."
cat <<EOF > ~/.config/zellij/layouts/dev-setup.kdl
layout {
    // Template for the editor pane
    pane_template name="editor" {
        command "nvim"
        size "70%"
        focus true // Focus on the editor on start
    }
    // Template for the terminal pane
    pane_template name="terminal" {
        // Takes up the remaining space
    }
    // Template for the bottom pane (for tests, logs, etc.)
    pane_template name="bottom_term" {
        size 10 // Height of 10 lines
    }

    // Main layout structure
    // A vertical split with the editor on the left and a terminal on the right
    pane split_direction="vertical" {
        pane name="editor"
        pane name="terminal"
    }

    // A horizontal split for the bottom terminal
    pane split_direction="horizontal" {
        pane name="bottom_term"
    }
}
EOF

# --- Zsh Integration ---
ZSHRC_PATH="/home/panch/dev_projects/zsh-ide-config/.zshrc"
echo "🔗 Integrating with Zsh at $ZSHRC_PATH..."

# Check if aliases are already present
if ! grep -q "# Aliases for Zellij IDE setup" "\$ZSHRC_PATH"; then
    echo "    - Adding aliases to .zshrc..."
    cat <<EOF >> "\$ZSHRC_PATH"

# Aliases for Zellij IDE setup
# zl: Start Zellij with the development layout
alias zl="zellij --layout dev-setup"
# za: Attach to the last Zellij session
alias za="zellij attach"
# zs: List all Zellij sessions
alias zs="zellij list-sessions"

# Use eza instead of ls for pretty, icon-rich listings
alias ls="eza --icons --group-directories-first"
alias la="eza -a --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first"
EOF
else
    echo "    - Aliases already found in .zshrc. Skipping."
fi

echo "✅ Setup complete!"
echo ""
echo "To apply the changes, please run:"
echo "source \$ZSHRC_PATH"
echo ""
echo "Then, you can use the new aliases:"
echo "  zl - Start a new Zellij development session"
echo "  za - Attach to an existing session"
echo "  ls - List files with icons"
