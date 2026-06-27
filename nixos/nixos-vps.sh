#!/usr/bin/env bash
# nixos-vps.sh — Hardening VPS no NixOS via configuration.nix
set -e

CONFIG="/etc/nixos/configuration.nix"
NEW_SSH_PORT=2222
ADMIN_USER="mervy"

echo "=== Configurando hardening VPS no NixOS ==="

if grep -q "services.fail2ban" "$CONFIG"; then
  echo "Hardening já declarado em configuration.nix."
else
  sudo sed -i '/^}$/i\
\
  # Hardening VPS\
  services.fail2ban = {\
    enable = true;\
    maxretry = 3;\
    bantime = "24h";\
  };\
\
  services.openssh = {\
    enable = true;\
    ports = [ '"${NEW_SSH_PORT}"' ];\
    settings = {\
      PermitRootLogin = "no";\
      PasswordAuthentication = true;\
    };\
  };\
\
  networking.firewall = {\
    enable = true;\
    allowedTCPPorts = [ '"${NEW_SSH_PORT}"' 80 443 9090 ];\
  };\
\
  environment.systemPackages = with pkgs; [ btop glances htop ncdu iftop fastfetch ];\
' "$CONFIG"
fi

sudo nixos-rebuild switch

echo ""
echo "========================================="
echo " VPS Hardening (NixOS) concluído!"
echo "========================================="
echo "  Nova porta SSH : ${NEW_SSH_PORT}"
echo "  Firewall       : nftables (gerenciado pelo NixOS)"
echo "  Fail2ban       : systemctl status fail2ban"
echo "  Monitoramento  : btop / glances"
echo ""
echo "  Abra um NOVO terminal antes de fechar esta sessão:"
echo "  ssh -p ${NEW_SSH_PORT} ${ADMIN_USER}@SEU_IP"
echo "========================================="
