#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando pacotes essenciais no openSUSE ==="
zypper refresh
zypper update -y
zypper install -y curl wget git gh unrar rar
zypper addrepo -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
zypper install --allow-unsigned-rpm -y unrar
echo "Essenciais instalados."

