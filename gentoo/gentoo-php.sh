#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando PHP no Gentoo ==="

# USE flags mínimas para PHP + extensões comuns
cat >> /etc/portage/package.use/php <<'EOF'
dev-lang/php curl mysql pgsql fpm cli unicode zip gd xml
EOF

emerge dev-lang/php
emerge dev-php/composer dev-php/xdebug

rc-update add php-fpm default
rc-service php-fpm start
echo "PHP instalado: $(php -v | head -1)"
