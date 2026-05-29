#!/bin/bash
set -e
echo "=== Instalando pacotes essenciais no Debian ==="
apt update && apt upgrade -y
apt install -y curl wget git gh unrar rar
echo "Essenciais instalados."