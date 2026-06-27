#!/usr/bin/env bash
# nixos-postgres.sh — PostgreSQL via configuration.nix
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
ADMIN_PASS="${POSTGRES_ADMIN_PASS:-DEFINA_SUA_SENHA}"

CONFIG="/etc/nixos/configuration.nix"

echo "=== Habilitando PostgreSQL no NixOS ==="

if grep -q "services.postgresql" "$CONFIG"; then
  echo "PostgreSQL já declarado em configuration.nix."
else
  sudo sed -i '/^}$/i\
\
  services.postgresql = {\
    enable = true;\
    enableTCPIP = true;\
    authentication = pkgs.lib.mkOverride 10 '"'"'local all all trust\nhost  all all 127.0.0.1/32 md5\n'"'"';\
  };\
' "$CONFIG"
fi

sudo nixos-rebuild switch
sleep 3

sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${ADMIN_PASS}';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE ROLE admin WITH LOGIN SUPERUSER PASSWORD '${ADMIN_PASS}';" 2>/dev/null || true

echo "✅ PostgreSQL instalado!"
echo "   Usuário : postgres / admin"
echo "   Senha   : ${ADMIN_PASS}"
echo "   sudo -u postgres psql"
