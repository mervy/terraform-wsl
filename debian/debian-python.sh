#!/usr/bin/env bash
# debian-python.sh — Python via pyenv (última versão estável)
set -e
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SHELL_DIR="$HOME/.config/shell"
mkdir -p "$SHELL_DIR"

echo "==> Instalando dependências de build..."
apt install -y \
  make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl \
  llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
  libxmlsec1-dev libffi-dev liblzma-dev

echo "==> Instalando pyenv..."
# PROFILE=/dev/null evita que o installer escreva no ~/.bashrc
PROFILE=/dev/null curl https://pyenv.run | bash

# Escreve exports no arquivo dedicado (não polui ~/.bashrc)
cat > "$SHELL_DIR/pyenv.sh" <<'EOF'
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

# Garante o loader no ~/.bashrc (uma única linha)
if ! grep -q 'config/shell' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Shell environment modules' >> ~/.bashrc
  echo 'for _f in "$HOME/.config/shell"/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f' >> ~/.bashrc
fi

# Carrega para a sessão atual
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo "==> Instalando Python mais recente..."
PYTHON_VER=$(pyenv install --list \
  | grep -E '^\s+3\.[0-9]+\.[0-9]+$' \
  | grep -v 'dev\|rc\|alpha\|beta' \
  | tail -1 | tr -d ' ')
pyenv install "$PYTHON_VER"
pyenv global "$PYTHON_VER"

echo "==> Instalando pipx e ferramentas globais..."
pip install --upgrade pip
pip install pipx
pipx ensurepath
pipx install poetry
pipx install black
pipx install ruff

echo ""
echo "========================================="
echo " Python ${PYTHON_VER} via pyenv OK!"
echo " Recarregue o shell: source ~/.bashrc"
echo " python --version"
echo " poetry --version"
echo "========================================="
