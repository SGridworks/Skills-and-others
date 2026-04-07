#!/usr/bin/env bash
set -euo pipefail

# Setup Tailscale on macOS (Mac Mini "mini2")
# Run this once when you have physical/remote access to mini2.
# After setup, you can always SSH in via: ssh <user>@mini2.<tailnet>.ts.net

HOSTNAME="mini2"

echo "=== Tailscale Setup for $HOSTNAME ==="
echo ""

# Check if running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "ERROR: This script is designed for macOS. Detected: $(uname -s)"
    exit 1
fi

# Check if Tailscale is already installed
if command -v /Applications/Tailscale.app/Contents/MacOS/Tailscale &>/dev/null; then
    echo "Tailscale app is already installed."
elif brew list --cask tailscale &>/dev/null 2>&1; then
    echo "Tailscale is already installed via Homebrew."
else
    echo "Installing Tailscale via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "ERROR: Homebrew is not installed. Install it first:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    brew install --cask tailscale
    echo "Tailscale installed."
fi

echo ""
echo "=== Enabling SSH and Screen Sharing ==="

# Enable Remote Login (SSH) if not already enabled
if sudo systemsetup -getremotelogin | grep -q "On"; then
    echo "Remote Login (SSH) is already enabled."
else
    echo "Enabling Remote Login (SSH)..."
    sudo systemsetup -setremotelogin on
    echo "Remote Login enabled."
fi

echo ""
echo "=== Post-Install Steps ==="
echo ""
echo "1. Open Tailscale from Applications (or menu bar)"
echo "2. Sign in with your Tailscale account"
echo "3. Once connected, enable Tailscale SSH:"
echo ""
echo "   Go to Tailscale Admin Console → Machines → $HOSTNAME → Enable Tailscale SSH"
echo "   Or run:  tailscale up --ssh --hostname=$HOSTNAME"
echo ""
echo "4. From any device on your tailnet, connect with:"
echo "   ssh $(whoami)@${HOSTNAME}.<your-tailnet>.ts.net"
echo ""
echo "5. To restart Hermes gateway remotely:"
echo "   ssh $(whoami)@${HOSTNAME}.<your-tailnet>.ts.net 'hermes restart gateway'"
echo ""
echo "=== Optional: Enable Tailscale to start at login ==="
echo "   System Settings → General → Login Items → add Tailscale"
echo ""
echo "Done! After signing in to Tailscale, $HOSTNAME will be reachable from anywhere."
