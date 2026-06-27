#!/usr/bin/env bash
# setup-go.sh — Go (última versão via download oficial — funciona em qualquer distro Linux)
set -e

SHELL_DIR="$HOME/.config/shell"
mkdir -p "$SHELL_DIR"

echo "==> Buscando última versão do Go..."
GO_VER=$(curl -sL https://go.dev/VERSION?m=text | head -1)
GO_TAR="${GO_VER}.linux-amd64.tar.gz"

echo "==> Baixando Go ${GO_VER}..."
curl -fsSL "https://go.dev/dl/${GO_TAR}" -o /tmp/${GO_TAR}

echo "==> Instalando em /usr/local/go..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/${GO_TAR}
rm -f /tmp/${GO_TAR}

# Escreve exports no arquivo dedicado (não polui ~/.bashrc)
cat > "$SHELL_DIR/go.sh" <<'EOF'
# Go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
EOF

# Garante o loader no ~/.bashrc (uma única linha)
if ! grep -q 'config/shell' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Shell environment modules' >> ~/.bashrc
  echo 'for _f in "$HOME/.config/shell"/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f' >> ~/.bashrc
fi

export PATH=$PATH:/usr/local/go/bin

echo ""
echo "========================================="
echo " Go ${GO_VER} instalado!"
echo " Recarregue o shell: source ~/.bashrc"
echo " go version"
echo " go env GOPATH"
echo "========================================="
