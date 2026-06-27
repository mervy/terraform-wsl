#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
POSTGRES_ADMIN_PASS="${POSTGRES_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando PostgreSQL no openSUSE ==="
zypper --non-interactive install postgresql-server postgresql-contrib
[ ! -f /var/lib/pgsql/data/PG_VERSION ] && sudo -u postgres initdb -D /var/lib/pgsql/data
systemctl enable --now postgresql
sleep 3
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '"${POSTGRES_ADMIN_PASS}"';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE ROLE admin WITH LOGIN SUPERUSER PASSWORD '"${POSTGRES_ADMIN_PASS}"';" 2>/dev/null || true
echo "PostgreSQL instalado."
