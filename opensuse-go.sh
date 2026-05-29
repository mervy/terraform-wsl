#!/bin/bash
set -e
echo "=== Instalando Go no openSUSE ==="
zypper install -y go
echo "Go: $(go version)"