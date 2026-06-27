#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalando pacotes essenciais no Arch ==="
pacman -Syu --noconfirm
pacman -S --noconfirm curl wget git github-cli unrar rar base-devel fastfetch

# Copiar bashrc ideal
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
cp "$SCRIPT_DIR/../agnostics/bashrc-ideal.txt" "$TARGET_HOME/.bashrc"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
echo "==> ~/.bashrc atualizado para $TARGET_USER"

echo "Essenciais instalados."
