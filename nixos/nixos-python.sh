#!/usr/bin/env bash
# nixos-python.sh — Python via nix profile (última versão disponível)
set -e

echo "=== Instalando Python no NixOS ==="

nix profile install \
  nixpkgs#python3 \
  nixpkgs#python3Packages.pip \
  nixpkgs#python3Packages.virtualenv

# pipx para ferramentas globais
nix profile install nixpkgs#pipx
pipx ensurepath
pipx install poetry
pipx install black
pipx install ruff

echo "✅ Python instalado!"
echo "   python3 --version"
echo "   pip --version"
echo "   poetry --version"
