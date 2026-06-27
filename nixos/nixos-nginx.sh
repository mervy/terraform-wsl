#!/usr/bin/env bash
# nixos-nginx.sh — Nginx via configuration.nix
set -e

CONFIG="/etc/nixos/configuration.nix"

echo "=== Habilitando Nginx no NixOS ==="

if grep -q "services.nginx" "$CONFIG"; then
  echo "Nginx já declarado em configuration.nix."
else
  sudo sed -i '/^}$/i\
\
  services.nginx = {\
    enable = true;\
    recommendedGzipSettings = true;\
    recommendedOptimisation = true;\
    recommendedProxySettings = true;\
    recommendedTlsSettings = true;\
  };\
\
  networking.firewall.allowedTCPPorts = [ 80 443 ];\
' "$CONFIG"
fi

sudo nixos-rebuild switch

echo "✅ Nginx instalado e ativo!"
echo "   nginx -t"
echo "   systemctl status nginx"
echo "   Config: /etc/nginx/nginx.conf"
