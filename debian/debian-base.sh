#!/usr/bin/env bash
# debian-base.sh — configuração inicial do Debian no WSL
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo "==> Instalando utilitários base..."
sudo apt install -y \
  curl wget git unzip zip \
  build-essential ca-certificates gnupg \
  apt-transport-https \
  lsb-release sudo vim nano htop \
  net-tools dnsutils bash-completion \
  gh unrar rar

echo "==> Instalando Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

echo "==> Base pronta."