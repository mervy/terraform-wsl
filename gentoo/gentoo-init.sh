#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
SYSTEM_USER_PASS="${SYSTEM_USER_PASS:-DEFINA_SUA_SENHA}"

echo "=== Configuração inicial do Gentoo (WSL) ==="

# Senha do root
echo "==> Definindo senha do root..."
echo "root:${SYSTEM_USER_PASS}" | chpasswd

# Criar usuário
read -rp "Nome do novo usuário: " USERNAME
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "${USERNAME}:${SYSTEM_USER_PASS}" | chpasswd
echo "Usuário '$USERNAME' criado com senha: ${SYSTEM_USER_PASS}"

# Instalar sudo e configurar wheel
echo "==> Instalando sudo..."
emerge --ask=n app-admin/sudo

echo "==> Habilitando sudo para o grupo wheel..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Definir usuário padrão no WSL
echo "==> Configurando usuário padrão no WSL..."
cat > /etc/wsl.conf <<EOF
[user]
default=${USERNAME}

[boot]
systemd=true
EOF

echo ""
echo "========================================="
echo " Configuração concluída!"
echo " Usuário : $USERNAME"
echo " Senha   : ${SYSTEM_USER_PASS} (root e $USERNAME)"
echo ""
echo " Reinicie o WSL para aplicar o usuário padrão:"
echo "   wsl --terminate Gentoo_v2"
echo "   wsl -d Gentoo_v2"
echo "========================================="
