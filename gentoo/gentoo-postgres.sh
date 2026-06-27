#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
POSTGRES_ADMIN_PASS="${POSTGRES_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando PostgreSQL via portage no Gentoo ==="
emerge dev-db/postgresql

PG_SLOT=$(ls /usr/lib/postgresql/ 2>/dev/null | sort -V | tail -1)
PG_SLOT="${PG_SLOT:-17}"

emerge --config "dev-db/postgresql:${PG_SLOT}" 2>/dev/null || true
rc-update add postgresql-"${PG_SLOT}" default
rc-service postgresql-"${PG_SLOT}" start
sleep 3

sudo -u postgres psql -c "ALTER USER postgres PASSWORD '"${POSTGRES_ADMIN_PASS}"';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE ROLE admin WITH LOGIN SUPERUSER PASSWORD '"${POSTGRES_ADMIN_PASS}"';" 2>/dev/null || true

echo ""
echo "========================================="
echo " $(sudo -u postgres psql -c 'SELECT version();' -t 2>/dev/null | head -1 | xargs)"
echo " Senha postgres e admin : ${POSTGRES_ADMIN_PASS}"
echo ""
echo " Para conectar:"
echo "   psql -U postgres -h localhost -W"
echo "========================================="
