#!/bin/bash
set -e
echo "=== Instalando MongoDB 8.3 no Arch ==="
# Usando pacotes do AUR ou repositório não oficial? Vamos usar o repositório oficial do MongoDB para Debian (via script) - adaptado para Arch.
# Infelizmente o MongoDB não fornece repositório nativo para Arch, então usamos AUR via yay ou baixamos binário.
pacman -S --noconfirm --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si --noconfirm
yay -S --noconfirm mongodb-bin mongosh-bin mongodb-tools-bin
systemctl enable --now mongodb
mongosh --eval "use admin; db.createUser({user:'admin', pwd:'M1nh*S_3n7A', roles:['root']})"
echo "MongoDB 8.3 instalado via AUR."