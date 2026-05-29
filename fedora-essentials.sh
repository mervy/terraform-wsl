#!/bin/bash
set -e
echo "=== Instalando pacotes essenciais no Fedora ==="
dnf update -y
dnf install -y curl wget git gh unrar rar
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
echo "Essenciais instalados com sucesso."