#!/usr/bin/env bash
# setup-node.sh — Node.js latest via nvm (funciona em qualquer distro Linux)
set -e

SHELL_DIR="$HOME/.config/shell"
mkdir -p "$SHELL_DIR"

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

# Aponta o instalador do nvm para o arquivo dedicado (não polui ~/.bashrc)
export PROFILE="$SHELL_DIR/node.sh"

echo "==> Instalando nvm (Node Version Manager)..."
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash

# Garante o loader no ~/.bashrc (uma única linha)
if ! grep -q 'config/shell' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Shell environment modules' >> ~/.bashrc
  echo 'for _f in "$HOME/.config/shell"/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f' >> ~/.bashrc
fi

# Carrega nvm na sessão atual
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "==> Instalando Node.js (última versão)..."
nvm install node
nvm use node
nvm alias default node

echo "==> Instalando pacotes globais úteis..."
npm install -g \
  pnpm \
  yarn \
  nodemon \
  pm2 \
  typescript \
  ts-node \
  @types/node

echo ""
echo "========================================="
echo " Node.js instalado via nvm!"
echo " node --version"
echo " npm --version"
echo " Para ativar no shell atual:"
echo "   source ~/.bashrc"
echo "========================================="
