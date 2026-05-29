#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Go (última versão) no Debian ==="
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
wget -c https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin
echo "Go: $(go version)"