#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalando pacotes essenciais no Gentoo ==="
emaint sync -a
emerge -uDN --with-bdeps=y @world
emerge net-misc/curl net-misc/wget dev-vcs/git dev-util/github-cli \
  app-arch/tar app-arch/unzip app-arch/zip app-arch/unrar app-arch/rar \
  app-editors/nano app-editors/vim sys-process/htop app-misc/tmux \
  app-shells/bash-completion net-tools/net-tools app-misc/fastfetch

echo "==> Instalando Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
SHELL_DIR="$HOME/.config/shell"
mkdir -p "$SHELL_DIR"
cat > "$SHELL_DIR/claude.sh" <<'EOF'
# Claude Code
export PATH="$HOME/.local/bin:$PATH"
EOF
if ! grep -q 'config/shell' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Shell environment modules' >> ~/.bashrc
  echo 'for _f in "$HOME/.config/shell"/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f' >> ~/.bashrc
fi

echo "==> Instalando OpenCode..."
curl -fsSL https://opencode.ai/install | bash

echo "==> Instalando Codex..."
curl -fsSL https://chatgpt.com/codex/install.sh | sh

# Copiar bashrc ideal
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
cp "$SCRIPT_DIR/../agnostics/bashrc-ideal.txt" "$TARGET_HOME/.bashrc"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
echo "==> ~/.bashrc atualizado para $TARGET_USER"

echo "Essenciais instalados com sucesso."
