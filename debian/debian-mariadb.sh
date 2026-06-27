#!/usr/bin/env bash
# debian-mariadb.sh — MariaDB (última estável via repo oficial)
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "==> Adicionando repositório oficial MariaDB..."
curl -fsSL https://downloads.mariadb.com/MariaDB/mariadb_repo_setup \
  | bash -s -- --skip-maxscale

apt update
apt install -y mariadb-server mariadb-client

echo "==> Iniciando MariaDB..."
systemctl enable mariadb
systemctl start mariadb

echo "==> Configurando senha root e segurança..."
# Usa psql-style variable para evitar interpolação de senha no SQL
mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ADMIN_PASS//\'/\'\'}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;"

echo ""
echo "========================================="
echo " MariaDB instalado com sucesso!"
echo " Usuário : root"
echo " Senha   : ${ADMIN_PASS}"
echo " Guarde essa senha agora!"
echo "========================================="
echo " Acesso local   : mariadb -u root -p"
echo " String WSL→Win : mysql://root:SENHA@127.0.0.1:3306"
