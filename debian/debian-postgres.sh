#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
POSTGRES_ADMIN_PASS="${POSTGRES_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando PostgreSQL via PGDG no Debian ==="

# Repositório oficial PGDG
apt install -y curl ca-certificates lsb-release
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] \
https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  | tee /etc/apt/sources.list.d/pgdg.list
apt update
apt install -y postgresql postgresql-contrib
systemctl enable --now postgresql

# Configurar usuários com psql variable binding (evita interpolação de senha na SQL)
sudo -u postgres psql -v "pass=$POSTGRES_ADMIN_PASS" \
  -c "ALTER USER postgres WITH PASSWORD :'pass';"
sudo -u postgres psql -v "pass=$POSTGRES_ADMIN_PASS" \
  -c "CREATE ROLE admin WITH LOGIN SUPERUSER PASSWORD :'pass';" 2>/dev/null || true

echo "PostgreSQL instalado."
