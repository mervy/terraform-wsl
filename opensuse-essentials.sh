#!/bin/bash
set -e
echo "=== Instalando pacotes essenciais no openSUSE ==="
zypper refresh
zypper update -y
zypper install -y curl wget git gh unrar rar
zypper addrepo -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
zypper install --allow-unsigned-rpm -y unrar
echo "Essenciais instalados."

