#!/bin/bash
set -e
echo "=== Instalando Nginx no Arch ==="
pacman -S --noconfirm nginx
systemctl enable --now nginx
echo "Nginx instalado."