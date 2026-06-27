#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MONGODB_ADMIN_PASS="${MONGODB_ADMIN_PASS:-DEFINA_SUA_SENHA}"

# MongoDB não tem repo oficial para Arch — usa repo não-oficial via pacman.conf
echo "=== Instalando MongoDB no Arch (repo não-oficial) ==="
cat > /etc/pacman.d/mongodb.repo <<EOF
[mongodb]
Server = https://repo.mongodb.org/pacman/arch/\$arch/
SigLevel = Never
EOF

if ! grep -q "Include = /etc/pacman.d/mongodb.repo" /etc/pacman.conf; then
  echo -e "\n[mongodb]\nInclude = /etc/pacman.d/mongodb.repo" >> /etc/pacman.conf
fi

pacman -Sy --noconfirm mongodb mongodb-tools mongodb-mongosh
systemctl enable --now mongod
sleep 4

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

echo "MongoDB instalado — acesso somente com senha."
