#!/usr/bin/env bash
# nixos-php.sh — PHP + PHP-FPM via configuration.nix
set -e

CONFIG="/etc/nixos/configuration.nix"

echo "=== Habilitando PHP no NixOS ==="

if grep -q "services.phpfpm" "$CONFIG"; then
  echo "PHP-FPM já declarado em configuration.nix."
else
  sudo sed -i '/^}$/i\
\
  services.phpfpm.pools.www = {\
    user = "nobody";\
    settings = {\
      "listen.owner" = "nginx";\
      "pm" = "dynamic";\
      "pm.max_children" = 5;\
      "pm.start_servers" = 2;\
      "pm.min_spare_servers" = 1;\
      "pm.max_spare_servers" = 3;\
    };\
  };\
\
  environment.systemPackages = with pkgs; [\
    php\
    phpPackages.composer\
  ];\
' "$CONFIG"
fi

sudo nixos-rebuild switch

echo "✅ PHP instalado!"
echo "   php -v"
echo "   composer --version"
