#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalando pacotes essenciais no openSUSE ==="
zypper refresh
zypper update -y
zypper install -y curl wget git gh unrar rar fastfetch
zypper addrepo -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
zypper install --allow-unsigned-rpm -y unrar

# Copiar bashrc ideal
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
cp "$SCRIPT_DIR/../agnostics/bashrc-ideal.txt" "$TARGET_HOME/.bashrc"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
echo "==> ~/.bashrc atualizado para $TARGET_USER"

echo "Essenciais instalados."
