#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MySQL 9.x no Gentoo ==="

# Aceita a licença do MySQL
mkdir -p /etc/portage/package.license
echo "dev-db/mysql Oracle-DB-prerelease" >> /etc/portage/package.license/mysql

# Desmascarar versão 9.x (~amd64)
mkdir -p /etc/portage/package.accept_keywords
echo "dev-db/mysql ~amd64" >> /etc/portage/package.accept_keywords/mysql

emerge dev-db/mysql

emerge --config dev-db/mysql
rc-update add mysql default
rc-service mysql start
sleep 4

mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '"${MYSQL_ADMIN_PASS}"';" 2>/dev/null || true
mysql -u root -p'"${MYSQL_ADMIN_PASS}"' -e "
  CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '"${MYSQL_ADMIN_PASS}"';
  GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
  FLUSH PRIVILEGES;" 2>/dev/null || true

echo "MySQL 9.x instalado."
