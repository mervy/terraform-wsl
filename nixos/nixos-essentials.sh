#!/usr/bin/env bash
# nixos-essentials.sh — Ferramentas base no NixOS
set -e

echo "=== Atualizando canais NixOS ==="
sudo nix-channel --update

echo "=== Instalando ferramentas essenciais ==="
nix profile install \
  nixpkgs#curl \
  nixpkgs#wget \
  nixpkgs#git \
  nixpkgs#gh \
  nixpkgs#vim \
  nixpkgs#htop \
  nixpkgs#unzip \
  nixpkgs#p7zip

echo "✅ Essenciais instalados."
echo "   Atualize o sistema: sudo nixos-rebuild switch"
