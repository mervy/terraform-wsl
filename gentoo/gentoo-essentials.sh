#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

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

echo "Essenciais instalados com sucesso."
