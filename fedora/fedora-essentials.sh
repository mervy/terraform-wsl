#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalando pacotes essenciais no Fedora ==="
dnf update -y
dnf install -y curl wget git gh unrar rar fastfetch
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Copiar bashrc ideal
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
cp "$SCRIPT_DIR/../agnostics/bashrc-ideal.txt" "$TARGET_HOME/.bashrc"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
echo "==> ~/.bashrc atualizado para $TARGET_USER"

echo "Essenciais instalados com sucesso."
