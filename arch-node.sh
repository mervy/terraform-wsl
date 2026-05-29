#!/bin/bash
set -e
echo "=== Instalando Node.js via nvm no Arch ==="
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh',  | bash
source ~/.bashrc
nvm install node
nvm alias default node
echo "Node.js: $(node -v)"