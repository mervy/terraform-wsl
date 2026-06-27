#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MONGODB_ADMIN_PASS="${MONGODB_ADMIN_PASS:-DEFINA_SUA_SENHA}"

echo "=== Instalando MongoDB 8.3 via tarball no Gentoo ==="

MONGO_VER="8.3.2"
TARBALL="mongodb-linux-x86_64-rhel93-${MONGO_VER}.tgz"
URL="https://fastdl.mongodb.org/linux/${TARBALL}"

MONGOSH_VER="2.5.5"
MONGOSH_TARBALL="mongosh-${MONGOSH_VER}-linux-x64.tgz"
MONGOSH_URL="https://downloads.mongodb.com/compass/${MONGOSH_TARBALL}"

pkill mongod 2>/dev/null || true
sleep 1
rm -rf /opt/mongodb /opt/mongosh
rm -f /var/lib/mongodb/mongod.lock /tmp/mongodb-*.sock

echo "==> Baixando MongoDB ${MONGO_VER}..."
curl -fL "$URL" -o "/tmp/${TARBALL}"
tar -xzf "/tmp/${TARBALL}" -C /tmp
mv "/tmp/mongodb-linux-x86_64-rhel93-${MONGO_VER}" /opt/mongodb
rm -f "/tmp/${TARBALL}"

echo "==> Baixando mongosh ${MONGOSH_VER}..."
curl -fL "$MONGOSH_URL" -o "/tmp/${MONGOSH_TARBALL}"
tar -xzf "/tmp/${MONGOSH_TARBALL}" -C /tmp
mv "/tmp/mongosh-${MONGOSH_VER}-linux-x64" /opt/mongosh
rm -f "/tmp/${MONGOSH_TARBALL}"

ln -sf /opt/mongodb/bin/mongod  /usr/local/bin/mongod
ln -sf /opt/mongodb/bin/mongos  /usr/local/bin/mongos
ln -sf /opt/mongosh/bin/mongosh /usr/local/bin/mongosh

mkdir -p /var/lib/mongodb /var/log/mongodb /var/run/mongodb
useradd -r -s /sbin/nologin mongodb 2>/dev/null || true
chown mongodb:mongodb /var/lib/mongodb /var/log/mongodb /var/run/mongodb

# Primeira inicialização SEM auth para criar o usuário admin
cat > /etc/mongod.conf <<'EOF'
storage:
  dbPath: /var/lib/mongodb
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
net:
  bindIp: 127.0.0.1
  port: 27017
processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid
EOF

echo "==> Iniciando MongoDB (sem auth)..."
sudo -u mongodb mongod --config /etc/mongod.conf

echo "==> Aguardando MongoDB iniciar..."
until mongosh --quiet --eval "db.runCommand({ping:1})" &>/dev/null; do sleep 1; done

echo "==> Criando usuário admin..."
mongosh admin --eval "
  db.createUser({user:'admin', pwd:'"${MONGODB_ADMIN_PASS}"', roles:[{role:'root',db:'admin'}]})
" 2>/dev/null || true

# Para e reescreve config COM auth
pkill mongod 2>/dev/null || true
sleep 1

cat > /etc/mongod.conf <<'EOF'
storage:
  dbPath: /var/lib/mongodb
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
net:
  bindIp: 127.0.0.1
  port: 27017
processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid
security:
  authorization: enabled
EOF

echo "==> Reiniciando com autenticação habilitada..."
sudo -u mongodb mongod --config /etc/mongod.conf

echo "==> Aguardando MongoDB reiniciar..."
until mongosh --quiet --eval "db.runCommand({ping:1})" -u admin -p '"${MONGODB_ADMIN_PASS}"' --authenticationDatabase admin &>/dev/null; do sleep 1; done

echo ""
echo "========================================="
echo " MongoDB ${MONGO_VER} instalado!"
echo " Para iniciar: sudo -u mongodb mongod --config /etc/mongod.conf"
echo " Para conectar: mongosh -u admin -p '"${MONGODB_ADMIN_PASS}"' --authenticationDatabase admin"
echo "========================================="
