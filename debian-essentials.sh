#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando pacotes essenciais no Debian ==="
apt update && apt upgrade -y
apt install -y curl wget git gh unrar rar
echo "Essenciais instalados."