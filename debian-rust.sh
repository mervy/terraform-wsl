#!/bin/bash
set -e
echo "=== Instalando Rust no Debian ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
echo "Rust: $(rustc --version)"