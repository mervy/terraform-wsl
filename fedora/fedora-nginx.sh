#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Nginx (última versão estável) no Fedora ==="
dnf install -y nginx
systemctl enable --now nginx
echo "Nginx instalado e em execução."