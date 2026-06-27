#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

# MySQL não está nos repos oficiais do Arch — instala via AUR com yay
echo "=== Instalando MySQL no Arch (via AUR) ==="

# yay não pode rodar como root — precisa de um usuário normal
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
if [[ -z "$REAL_USER" || "$REAL_USER" == "root" ]]; then
  echo "❌ Defina SUDO_USER ou rode com: sudo -u seuusuario $0"
  exit 1
fi

pacman -S --noconfirm --needed git base-devel

# Instala yay se não existir
if ! command -v yay &>/dev/null; then
  sudo -u "$REAL_USER" bash -c "
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
  "
fi

sudo -u "$REAL_USER" yay -S --noconfirm mysql
systemctl enable --now mysqld
sleep 4
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '"${MYSQL_ADMIN_PASS}"'; FLUSH PRIVILEGES;" 2>/dev/null || true
mysql -u root -p'"${MYSQL_ADMIN_PASS}"' -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '"${MYSQL_ADMIN_PASS}"'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true
echo "MySQL instalado."
