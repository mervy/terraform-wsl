#!/usr/bin/env bash
# git-config-init.sh — configuração global do Git após reinstalação

set -e

echo "======================================="
echo " Git — Configuração Inicial"
echo "======================================="
echo ""
echo "Escolha o perfil de usuário:"
echo "  1) Rogério Soares  <rgrsoares@yahoo.com.br>"
echo "  2) Mr. Protect Codes  <codevault@ungeeksi.dev.net>"
echo ""
read -rp "Perfil [1/2]: " PERFIL

case "$PERFIL" in
  1)
    GIT_NAME="Rogério Soares"
    GIT_EMAIL="rgrsoares@yahoo.com.br"
    ;;
  2)
    GIT_NAME="Mr. Protect Codes"
    GIT_EMAIL="codevault@ungeeksi.dev.net"
    ;;
  *)
    echo "Opção inválida. Encerrando."
    exit 1
    ;;
esac

echo ""
echo "==> Aplicando configurações para: $GIT_NAME <$GIT_EMAIL>"
echo ""

# Identidade
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Editor padrão
git config --global core.editor "nano"

# Branch padrão
git config --global init.defaultBranch main

# Sempre criar merge commit (no fast-forward)
git config --global merge.ff no

# Cores no terminal
git config --global color.ui auto

# Evitar problemas de quebra de linha (Linux/Mac)
git config --global core.autocrlf input

# Alias: log resumido em grafo
git config --global alias.lg "log --oneline --graph --decorate --all"

# Alias: merge da dev em main com mensagem
# Uso: git gmerge "mensagem do commit"
git config --global alias.gmerge '!f() { git merge dev -m "merge (dev->main) $1"; }; f'

echo ""
echo "==> Configurações aplicadas:"
echo ""
git config --global --list
echo ""
echo "======================================="
echo " Pronto! Use 'git lg' para ver o log"
echo " e 'git gmerge \"mensagem\"' para merge."
echo "======================================="
