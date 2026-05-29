#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP 8.5.6 no Arch ==="
# Arch costuma ter a versão mais recente nos repositórios
pacman -S --noconfirm php php-fpm
systemctl enable --now php-fpm
echo "PHP instalado: $(php -v | head -1)"