#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MONGODB_ADMIN_PASS="${MONGODB_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MongoDB 8.3 no Debian ==="
curl -fsSL https://www.mongodb.org/static/pgp/server-8.3.asc | gpg -o /usr/share/keyrings/mongodb-server-8.3.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.3.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.3 main" | tee /etc/apt/sources.list.d/mongodb-org-8.3.list
apt update
apt install -y mongodb-org mongodb-mongosh mongodb-org-tools
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