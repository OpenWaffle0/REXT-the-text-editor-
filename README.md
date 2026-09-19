# Rext (The Text Editor)

A ultra-minimalist, fast, and terminal-friendly text editor written in Lua. Designed for speed, resource efficiency, and simple terminal navigation without heavy dependencies.

---

## Features

- **Ultra Lightweight:** Minimal RAM footprint powered by Lua.
- **UTF-8 Support:** Full unicode rendering for terminal environments.
- **Advanced Terminal Shortcuts:**
  - `Ctrl + A`: Move cursor to the beginning of the line
  - `Ctrl + E`: Move cursor to the end of the line
  - `Ctrl + K`: Kill (delete) line from cursor to end
  - `PageUp` / `PageDown`: Fast screen scrolling
- **Native Terminal Control:** Direct `stty` state handling.

---

## Installation (Arch Linux / Arch-based Distros)

You can build and install Rext directly from this repository using `makepkg`.

### Prerequisites

Ensure you have `git`, `base-devel`, and `lua` installed:


$ sudo pacman -S --needed git base-devel lua

Building & Installing
⚠️ CRITICAL: DO NOT FORGET THE --skipchecksums FLAG!
Since the PKGBUILD uses local/dynamic source references during manual builds, skipping checksum verification is REQUIRED to prevent build failures.

Run the following commands in your terminal step-by-step:

Bash
# 1. Clone the repository
`$ git clone [https://github.com/OpenWaffle0/REXT-the-text-editor-.git](https://github.com/OpenWaffle0/REXT-the-text-editor-.git)`

# 2. Navigate to the project directory
`$ cd REXT-the-text-editor-`

# 3. Build and install the package (DO NOT FORGET --skipchecksums!)
`$ makepkg -si --skipchecksums`
Usage
To open or create a file with Rext, simply run:

Bash
`$ rext filename.txt`
Or just run rext to start with a fresh buffer:

Bash
`$ rext`
Uninstallation
To remove Rext from your system:

Bash
`$ sudo pacman -R rext`
