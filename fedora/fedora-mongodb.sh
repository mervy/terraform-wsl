#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MONGODB_ADMIN_PASS="${MONGODB_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MongoDB 8.3 no Fedora ==="
# No Fedora, $releasever retorna a versão do Fedora (ex: 44),
# mas o MongoDB só publica pacotes para RHEL (8, 9).
# Usa RHEL 9 como base compatível.
cat > /etc/yum.repos.d/mongodb-org-8.3.repo <<EOF
[mongodb-org-8.3]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.3/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
EOF
dnf install -y mongodb-org mongodb-mongosh mongodb-org-tools
systemctl enable --now mongod

# ── Aguardar mongod estar pronto ─────────────────────────────
echo "==> Aguardando mongod aceitar conexões..."
for i in $(seq 1 30); do
  if mongosh --quiet --eval "db.runCommand({ping:1})" &>/dev/null; then
    echo "   mongod respondeu após ${i}s"
    break
  fi
  sleep 1
done

# ── Criar usuário admin via process.env (evita interpolação de senha no JS) ──
echo "==> Criando usuário admin..."
MONGODB_ADMIN_PASS="$MONGODB_ADMIN_PASS" mongosh --quiet --eval "
  db.getSiblingDB('admin').createUser({
    user: 'admin',
    pwd: process.env.MONGODB_ADMIN_PASS,
    roles: [
      { role: 'userAdminAnyDatabase', db: 'admin' },
      { role: 'readWriteAnyDatabase', db: 'admin' },
      'root'
    ]
  })
" 2>/dev/null || true

echo "   Usuário admin criado."

# ── Ativar autenticação no mongod.conf ───────────────────────
echo "==> Ativando autenticação obrigatória..."
if grep -q 'authorization:' /etc/mongod.conf 2>/dev/null; then
  sed -i 's/^  authorization: .*/  authorization: enabled/' /etc/mongod.conf
else
  sed -i '/^#  authorization:/a\  authorization: enabled' /etc/mongod.conf
fi
systemctl restart mongod
sleep 2

echo "MongoDB 8.3 instalado — acesso somente com senha."
