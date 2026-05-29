#!/bin/bash
set -e
echo "=== Instalando Go no Arch ==="
pacman -S --noconfirm go
echo "Go: $(go version)"