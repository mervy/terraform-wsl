#!/bin/bash
set -e
echo "=== Instalando Nginx (última versão estável) no Fedora ==="
dnf install -y nginx
systemctl enable --now nginx
echo "Nginx instalado e em execução."