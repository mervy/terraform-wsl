#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Nginx via repo oficial no Fedora ==="
# Tenta o repo oficial do nginx; se a versão do Fedora não tiver
# suporte, usa o pacote nativo do Fedora como fallback.
FEDORA_VER=$(rpm -E %fedora)
NGINX_REPO="https://nginx.org/packages/fedora/${FEDORA_VER}/nginx.repo"
if curl -sIf "$NGINX_REPO" >/dev/null 2>&1; then
  dnf install -y 'dnf5-command(config-manager)' 2>/dev/null || dnf install -y 'dnf-command(config-manager)'
  dnf config-manager --add-repo "$NGINX_REPO"
fi
dnf install -y nginx
systemctl enable --now nginx
echo "Nginx instalado: $(nginx -v 2>&1)"
