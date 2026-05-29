#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP 8.5.6 no Fedora (Remi) ==="
dnf install -y https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm
dnf module reset php -y
dnf module install php:remi-8.5 -y
dnf install -y php php-cli php-fpm php-mysqlnd php-pgsql php-mongodb
systemctl enable --now php-fpm
echo "PHP instalado: $(php -v | head -1)"