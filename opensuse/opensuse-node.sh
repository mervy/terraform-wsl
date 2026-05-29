#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }
export NVM_DIR="$HOME/.nvm" && mkdir -p "$NVM_DIR"

echo "=== Instalando Node.js via nvm no openSUSE ==="
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node
nvm alias default node
echo "Node.js: $(node -v)"