#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Nginx no openSUSE ==="
zypper addrepo https://nginx.org/packages/suse/$(grep -oP 'VERSION_ID="\K[0-9]+' /etc/os-release)/nginx.repo
zypper refresh
zypper install -y nginx
systemctl enable --now nginx
echo "Nginx instalado."