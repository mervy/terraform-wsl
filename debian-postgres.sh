#!/bin/bash
set -e
echo "=== Instalando PostgreSQL no Debian ==="
apt install -y postgresql postgresql-contrib
systemctl enable --now postgresql
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'M1nh*S_3n7A';"
echo "PostgreSQL instalado."