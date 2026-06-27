#!/usr/bin/env bash
# setup-rust.sh — Rust via rustup (funciona em qualquer distro Linux)
set -e

SHELL_DIR="$HOME/.config/shell"
mkdir -p "$SHELL_DIR"

echo "==> Instalando dependências de build..."
if command -v apt &>/dev/null; then
  sudo apt install -y build-essential pkg-config libssl-dev
elif command -v dnf &>/dev/null; then
  sudo dnf install -y gcc pkg-config openssl-devel
elif command -v pacman &>/dev/null; then
  sudo pacman -S --noconfirm base-devel pkg-config openssl
elif command -v zypper &>/dev/null; then
  sudo zypper install -y gcc pkg-config libopenssl-devel
fi

echo "==> Instalando Rust via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Escreve exports no arquivo dedicado (não polui ~/.bashrc)
cat > "$SHELL_DIR/rust.sh" <<'EOF'
# Rust
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
EOF

# Garante o loader no ~/.bashrc (uma única linha)
if ! grep -q 'config/shell' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Shell environment modules' >> ~/.bashrc
  echo 'for _f in "$HOME/.config/shell"/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f' >> ~/.bashrc
fi

# Carrega para a sessão atual
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

echo "==> Instalando componentes úteis..."
rustup component add clippy rustfmt rust-analyzer
rustup target add wasm32-unknown-unknown

echo ""
echo "========================================="
echo " Rust instalado!"
echo " Recarregue o shell: source ~/.bashrc"
echo " rustc --version"
echo " cargo --version"
echo " rustup show"
echo "========================================="
