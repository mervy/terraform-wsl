#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Go no Arch ==="
pacman -S --noconfirm go
echo "Go: $(go version)"