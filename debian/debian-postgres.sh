#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
POSTGRES_ADMIN_PASS="${POSTGRES_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando PostgreSQL no Debian ==="
apt install -y postgresql postgresql-contrib
systemctl enable --now postgresql
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '"${POSTGRES_ADMIN_PASS}"';"
echo "PostgreSQL instalado."