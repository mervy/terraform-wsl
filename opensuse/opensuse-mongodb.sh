#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MONGODB_ADMIN_PASS="${MONGODB_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MongoDB 8.3 no openSUSE ==="
rpm --import https://www.mongodb.org/static/pgp/server-8.3.asc
zypper addrepo --gpgcheck "https://repo.mongodb.org/zypper/suse/15/mongodb-org/8.3/x86_64/" mongodb
zypper refresh
zypper install -y mongodb-org mongosh mongodb-org-tools
systemctl enable --now mongod
sleep 3

# ── Criar usuário admin ──────────────────────────────────────
echo "==> Criando usuário admin..."
mongosh --quiet --eval "
  use admin;
  db.createUser({
    user: 'admin',
    pwd: '"${MONGODB_ADMIN_PASS}"',
    roles: [
      { role: 'userAdminAnyDatabase', db: 'admin' },
      { role: 'readWriteAnyDatabase', db: 'admin' },
      'root'
    ]
  })
" 2>/dev/null || mongosh --quiet /dev/stdin <<JSEOF
use admin;
db.createUser({user:'admin',pwd:'"${MONGODB_ADMIN_PASS}"',roles:['root']})
JSEOF

# ── Ativar autenticação ─────────────────────────────────────
echo "==> Ativando autenticação obrigatória..."
if grep -q 'authorization:' /etc/mongod.conf 2>/dev/null; then
  sed -i 's/^  authorization: .*/  authorization: enabled/' /etc/mongod.conf
else
  sed -i '/^#  authorization:/a\  authorization: enabled' /etc/mongod.conf
fi
systemctl restart mongod
sleep 2

echo "MongoDB 8.3 instalado — acesso somente com senha."