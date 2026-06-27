#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MySQL 9.7 no Debian ==="
curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 \
  | gpg --dearmor -o /etc/apt/trusted.gpg.d/mysql.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/mysql.gpg] https://repo.mysql.com/apt/debian/ $(lsb_release -cs) mysql-9.7" \
  | tee /etc/apt/sources.list.d/mysql.list
apt update
apt install -y mysql-community-server
systemctl enable --now mysql
sleep 4
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '"${MYSQL_ADMIN_PASS}"';" 2>/dev/null || true
mysql -u root -p'"${MYSQL_ADMIN_PASS}"' -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '"${MYSQL_ADMIN_PASS}"'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true
echo "MySQL instalado."
