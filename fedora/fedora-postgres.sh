#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
POSTGRES_ADMIN_PASS="${POSTGRES_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando PostgreSQL 18 via repo pgdg no Fedora ==="

# Desabilitar módulo postgresql padrão do Fedora (se existir)
dnf module disable postgresql -y 2>/dev/null || true

# Instalar repo PGDG oficial
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-$(rpm -E %fedora)-x86_64/pgdg-fedora-repo-latest.noarch.rpm

# Instalar PostgreSQL 18
dnf install -y postgresql18-server postgresql18

# Inicializar e iniciar
/usr/pgsql-18/bin/postgresql-18-setup initdb 2>/dev/null || true
systemctl enable --now postgresql-18
sleep 3

# Configurar usuários com senha do .env
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '"${POSTGRES_ADMIN_PASS}"';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE ROLE admin WITH LOGIN SUPERUSER PASSWORD '"${POSTGRES_ADMIN_PASS}"';" 2>/dev/null || true

echo "PostgreSQL 18 instalado."
