#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando pacotes essenciais no Arch ==="
pacman -Syu --noconfirm
pacman -S --noconfirm curl wget git github-cli unrar rar base-devel
echo "Essenciais instalados."