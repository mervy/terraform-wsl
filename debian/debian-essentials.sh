#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalando pacotes essenciais no Debian ==="
apt update && apt upgrade -y
apt install -y curl wget git gh unrar rar

# Instalar fastfetch (disponível no Debian 13+; fallback para .deb do GitHub)
if apt-cache show fastfetch &>/dev/null 2>&1; then
  apt install -y fastfetch
else
  ARCH=$(dpkg --print-architecture)
  curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${ARCH}.deb" \
    -o /tmp/fastfetch.deb
  dpkg -i /tmp/fastfetch.deb
  rm -f /tmp/fastfetch.deb
fi

# Copiar bashrc ideal
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
cp "$SCRIPT_DIR/../agnostics/bashrc-ideal.txt" "$TARGET_HOME/.bashrc"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
echo "==> ~/.bashrc atualizado para $TARGET_USER"

echo "Essenciais instalados."
