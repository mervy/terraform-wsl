#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP 8.5 no Debian (Sury) ==="
apt install -y lsb-release ca-certificates apt-transport-https curl

# Repositório Sury (suporte oficial para Debian — não é PPA Ubuntu)
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg \
  https://packages.sury.org/php/apt.gpg
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] \
https://packages.sury.org/php/ $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/php.list

apt update
apt install -y php8.5 php8.5-cli php8.5-fpm php8.5-mysql php8.5-pgsql php8.5-mongodb
systemctl enable --now php8.5-fpm
echo "PHP: $(php -v | head -1)"
