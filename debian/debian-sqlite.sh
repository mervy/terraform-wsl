#!/usr/bin/env bash
# debian-sqlite.sh — SQLite (sem servidor, sem senha)
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Instalando SQLite3..."
sudo apt update
sudo apt install -y sqlite3 libsqlite3-dev

echo "==> Testando instalação..."
sqlite3 /tmp/teste.db <<EOF
CREATE TABLE teste (id INTEGER PRIMARY KEY, nome TEXT);
INSERT INTO teste VALUES (1, 'WSL SQLite funcionando');
SELECT * FROM teste;
EOF

rm /tmp/teste.db

echo ""
echo "========================================="
echo " SQLite instalado!"
echo " Uso: sqlite3 meu_banco.db"
echo " SQLite não tem servidor — arquivo local"
echo "========================================="
