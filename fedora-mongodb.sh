#!/bin/bash
set -e
echo "=== Instalando MongoDB 8.3 no Fedora ==="
cat > /etc/yum.repos.d/mongodb-org-8.3.repo <<EOF
[mongodb-org-8.3]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/8.3/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.3.asc
EOF
dnf install -y mongodb-org mongodb-mongosh mongodb-org-tools
systemctl enable --now mongod
mongosh --eval "use admin; db.createUser({user:'admin', pwd:'M1nh*S_3n7A', roles:['root']})"
echo "MongoDB 8.3 instalado."