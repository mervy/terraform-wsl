#!/usr/bin/env bash
# nixos-mysql.sh — MySQL via configuration.nix
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

CONFIG="/etc/nixos/configuration.nix"

echo "=== Habilitando MySQL no NixOS ==="

if grep -q "services.mysql" "$CONFIG"; then
  echo "MySQL já declarado em configuration.nix."
else
  sudo sed -i '/^}$/i\
\
  services.mysql = {\
    enable = true;\
    package = pkgs.mysql80;\
    settings.mysqld.bind-address = "127.0.0.1";\
  };\
' "$CONFIG"
fi

sudo nixos-rebuild switch
sleep 4

mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ADMIN_PASS}'; FLUSH PRIVILEGES;" 2>/dev/null || true
mysql -u root -p"${ADMIN_PASS}" -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '${ADMIN_PASS}'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true

echo "✅ MySQL instalado!"
echo "   Usuário : root / admin"
echo "   Senha   : ${ADMIN_PASS}"
