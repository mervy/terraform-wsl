#!/usr/bin/env bash
# nixos-essentials.sh — Ferramentas base no NixOS
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  nixpkgs#p7zip \
  nixpkgs#fastfetch

# Copiar bashrc ideal
cp "$SCRIPT_DIR/../agnostics/bashrc-ideal.txt" "$HOME/.bashrc"
echo "==> ~/.bashrc atualizado para $USER"

echo "✅ Essenciais instalados."
echo "   Atualize o sistema: sudo nixos-rebuild switch"
