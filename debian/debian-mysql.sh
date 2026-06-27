#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

# Escape single quotes for SQL string literals
SQL_PASS="${MYSQL_ADMIN_PASS//\'/\'\'}"

# Helper: cria arquivo de configuração temporário para evitar senha na linha de comando
_mysql_cnf() {
  local f; f=$(mktemp); chmod 600 "$f"
  printf '[client]\npassword=%s\n' "$1" > "$f"
  echo "$f"
}

echo "=== Instalando MySQL 9.7 no Debian ==="
curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 \
  | gpg --dearmor -o /etc/apt/trusted.gpg.d/mysql.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/mysql.gpg] https://repo.mysql.com/apt/debian/ $(lsb_release -cs) mysql-9.7" \
  | tee /etc/apt/sources.list.d/mysql.list
apt update
apt install -y mysql-community-server
systemctl enable --now mysql

# Aguardar MySQL estar pronto
echo "==> Aguardando MySQL aceitar conexões..."
for i in $(seq 1 30); do
  if mysql -u root -e "SELECT 1" &>/dev/null; then
    echo "   MySQL respondeu após ${i}s"
    break
  fi
  sleep 1
done

mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${SQL_PASS}';" 2>/dev/null || true

CNF=$(_mysql_cnf "$MYSQL_ADMIN_PASS")
trap "rm -f '$CNF'" EXIT
mysql --defaults-extra-file="$CNF" -u root -e "
  CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '${SQL_PASS}';
  GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
" 2>/dev/null || true

echo "MySQL instalado."
