#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando MongoDB 8.3 no openSUSE ==="
rpm --import https://www.mongodb.org/static/pgp/server-8.3.asc
zypper addrepo --gpgcheck "https://repo.mongodb.org/zypper/suse/15/mongodb-org/8.3/x86_64/" mongodb
zypper refresh
zypper install -y mongodb-org mongosh mongodb-org-tools
systemctl enable --now mongod
mongosh --eval "use admin; db.createUser({user:'admin', pwd:'M1nh*S_3n7A', roles:['root']})"
echo "MongoDB 8.3 instalado."