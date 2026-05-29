#!/bin/bash
set -e
echo "=== Instalando pacotes essenciais no Arch ==="
pacman -Syu --noconfirm
pacman -S --noconfirm curl wget git github-cli unrar rar base-devel
echo "Essenciais instalados."