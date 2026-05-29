#!/bin/bash
set -e
echo "=== Instalando PostgreSQL no Fedora ==="
dnf install -y postgresql-server postgresql-contrib
postgresql-setup --initdb
systemctl enable --now postgresql
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'M1nh*S_3n7A';"
echo "PostgreSQL instalado."