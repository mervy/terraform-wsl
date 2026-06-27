#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP 8.5.6 no Fedora (Remi) ==="
dnf install -y https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm

# DNF5 (Fedora 41+) não tem "module install", usa "module enable" + "install"
if dnf --version 2>&1 | grep -q '^dnf5'; then
  dnf module reset php -y 2>/dev/null || true
  dnf module enable php:remi-8.5 -y
else
  dnf module reset php -y 2>/dev/null || true
  dnf module install php:remi-8.5 -y 2>/dev/null || true
fi

dnf install -y php php-cli php-fpm php-mysqlnd php-pgsql php-mongodb

systemctl enable --now php-fpm
echo "PHP instalado: $(php -v | head -1)"