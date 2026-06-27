#!/usr/bin/env bash
# debian-base.sh — configuração inicial do Debian no WSL
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "==> Atualizando sistema..."
apt update && apt upgrade -y

echo "==> Instalando utilitários base..."
apt install -y \
  curl wget git unzip zip \
  build-essential ca-certificates gnupg \
  apt-transport-https \
  lsb-release sudo vim nano htop \
  net-tools dnsutils bash-completion \
  gh unrar rar

echo "==> Instalando Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

echo "==> Base pronta."
