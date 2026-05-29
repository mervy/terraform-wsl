#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Nginx no Arch ==="
pacman -S --noconfirm nginx
systemctl enable --now nginx
echo "Nginx instalado."