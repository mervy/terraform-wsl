#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP 8.5.6 no openSUSE ==="
zypper addrepo https://download.opensuse.org/repositories/devel:languages:php/openSUSE_Tumbleweed/devel:languages:php.repo
zypper refresh
zypper install -y php8 php8-fpm php8-mysql php8-pgsql php8-mongodb
systemctl enable --now php-fpm
echo "PHP: $(php -v | head -1)"