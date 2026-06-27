#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MySQL 9.7 no openSUSE ==="
zypper --non-interactive addrepo https://repo.mysql.com/yum/mysql-9.7-community/suse/15/mysql-9.7-community.suse15.repo
zypper --non-interactive refresh
zypper --non-interactive install mysql-community-server
systemctl enable --now mysql
sleep 4
TEMP_PASS=$(grep 'temporary password' /var/log/mysql/mysqld.log 2>/dev/null | tail -1 | awk '{print $NF}' || echo '')
if [[ -n "$TEMP_PASS" ]]; then
  mysql --connect-expired-password -uroot -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '"${MYSQL_ADMIN_PASS}"';
FLUSH PRIVILEGES;
EOF
fi
mysql -u root -p'"${MYSQL_ADMIN_PASS}"' -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '"${MYSQL_ADMIN_PASS}"'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true
echo "MySQL instalado."
