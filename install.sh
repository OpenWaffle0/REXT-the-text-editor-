#!/bin/sh
echo "Installing Rext Text Editor..."

# Check for Lua and attempt auto-installation based on distro package manager
if ! command -v lua >/dev/null 2>&1; then
    echo "[INFO] Lua is not installed. Attempting to install via package manager..."
    if command -v apk >/dev/null 2>&1; then
        # Chimera Linux & Alpine
        doas apk add lua5.4 2>/dev/null || sudo apk add lua5.4
    elif command -v xbps-install >/dev/null 2>&1; then
        # Void Linux
        doas xbps-install -S lua 2>/dev/null || sudo xbps-install -S lua
    elif command -v emerge >/dev/null 2>&1; then
        # Gentoo Linux
        doas emerge --ask dev-lang/lua 2>/dev/null || sudo emerge --ask dev-lang/lua
    elif command -v pacman >/dev/null 2>&1; then
        # Arch / CachyOS / Artix
        doas pacman -S --noconfirm lua 2>/dev/null || sudo pacman -S --noconfirm lua
    elif command -v apt >/dev/null 2>&1; then
        # Debian / Ubuntu
        sudo apt update && sudo apt install -y lua5.4
    else
        echo "[ERROR] Could not detect package manager. Please install Lua manually."
        exit 1
    fi
fi

# Copy binary to /usr/local/bin
if [ -w /usr/local/bin ]; then
    cp rext.lua /usr/local/bin/rext
    chmod +x /usr/local/bin/rext
else
    doas cp rext.lua /usr/local/bin/rext 2>/dev/null || sudo cp rext.lua /usr/local/bin/rext
    doas chmod +x /usr/local/bin/rext 2>/dev/null || sudo chmod +x /usr/local/bin/rext
fi

echo "[SUCCESS] Rext successfully installed to /usr/local/bin/rext"
EOF

chmod +x install.sh
