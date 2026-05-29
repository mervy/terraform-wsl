#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando MongoDB 8.3 no Debian ==="
curl -fsSL https://www.mongodb.org/static/pgp/server-8.3.asc | gpg -o /usr/share/keyrings/mongodb-server-8.3.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.3.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.3 main" | tee /etc/apt/sources.list.d/mongodb-org-8.3.list
apt update
apt install -y mongodb-org mongodb-mongosh mongodb-org-tools
systemctl enable --now mongod
mongosh --eval "use admin; db.createUser({user:'admin', pwd:'M1nh*S_3n7A', roles:['root']})"
echo "MongoDB 8.3 instalado."