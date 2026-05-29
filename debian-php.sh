#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP 8.5.6 no Debian (Ondrej) ==="
apt install -y lsb-release ca-certificates apt-transport-https software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.5 php8.5-cli php8.5-fpm php8.5-mysql php8.5-pgsql php8.5-mongodb
systemctl enable --now php8.5-fpm
echo "PHP: $(php -v | head -1)"