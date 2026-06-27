#!/usr/bin/env bash
# opensuse-python.sh — Python via pyenv (última versão estável)
set -e
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SHELL_DIR="$HOME/.config/shell"
mkdir -p "$SHELL_DIR"

echo "==> Instalando dependências de build..."
zypper --non-interactive install gcc make zlib-devel bzip2-devel readline-devel \
  sqlite3-devel openssl-devel tk-devel libffi-devel xz-devel

echo "==> Instalando pyenv..."
PROFILE=/dev/null curl https://pyenv.run | bash

cat > "$SHELL_DIR/pyenv.sh" <<'EOF'
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

if ! grep -q 'config/shell' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Shell environment modules' >> ~/.bashrc
  echo 'for _f in "$HOME/.config/shell"/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f' >> ~/.bashrc
fi

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

echo ""
echo "========================================="
echo " Python ${PYTHON_VER} via pyenv OK!"
echo " Recarregue o shell: source ~/.bashrc"
echo " python --version"
echo "========================================="
