#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Nginx no Debian ==="
apt install -y curl gnupg2 ca-certificates lsb-release
curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/nginx.gpg
echo "deb https://nginx.org/packages/debian $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
apt update
apt install -y nginx
systemctl enable --now nginx
echo "Nginx instalado."