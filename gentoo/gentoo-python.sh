#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando Python no Gentoo ==="
emerge dev-lang/python dev-python/pip

echo ""
echo "========================================="
echo " $(python3 --version)"
echo "========================================="
