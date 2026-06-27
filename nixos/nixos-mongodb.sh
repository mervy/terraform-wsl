#!/usr/bin/env bash
# nixos-mongodb.sh — MongoDB via configuration.nix
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
ADMIN_PASS="${MONGODB_ADMIN_PASS:-DEFINA_SUA_SENHA}"

CONFIG="/etc/nixos/configuration.nix"

echo "=== Habilitando MongoDB no NixOS ==="
echo "ATENÇÃO: MongoDB requer unfree packages habilitado."

if ! grep -q "allowUnfree = true" "$CONFIG"; then
  sudo sed -i '/^}$/i\
\
  nixpkgs.config.allowUnfree = true;\
' "$CONFIG"
fi

if grep -q "services.mongodb" "$CONFIG"; then
  echo "MongoDB já declarado em configuration.nix."
else
  sudo sed -i '/^}$/i\
\
  services.mongodb = {\
    enable = true;\
    bind_ip = "127.0.0.1";\
  };\
' "$CONFIG"
fi

sudo nixos-rebuild switch
sleep 4

mongosh --quiet <<EOF
use admin
db.createUser({
  user: "admin",
  pwd: "${ADMIN_PASS}",
  roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
})
EOF

echo "✅ MongoDB instalado!"
echo "   Usuário : admin"
echo "   Senha   : ${ADMIN_PASS}"
echo "   mongosh -u admin -p --authenticationDatabase admin"
