#!/bin/bash
set -e
echo "=== Instalando PostgreSQL no Arch ==="
pacman -S --noconfirm postgresql
su -c "initdb -D /var/lib/postgres/data" postgres
systemctl enable --now postgresql
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'M1nh*S_3n7A';"
echo "PostgreSQL instalado."