#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Nginx via repo oficial no Gentoo ==="
mkdir -p /etc/portage/package.use
echo "app-misc/mime-types nginx" >> /etc/portage/package.use/nginx
emerge www-servers/nginx
rc-update add nginx default
rc-service nginx start
echo "Nginx instalado: $(nginx -v 2>&1)"
