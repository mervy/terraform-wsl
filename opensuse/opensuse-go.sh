#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Go no openSUSE ==="
zypper install -y go
echo "Go: $(go version)"