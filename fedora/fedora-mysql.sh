#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

# Escape single quotes para SQL string literals
SQL_PASS="${MYSQL_ADMIN_PASS//\'/\'\'}"

# Senha temporária gerada em runtime — nunca versionada
BOOTSTRAP_PASS=$(openssl rand -base64 18 | tr -d '+/=' | head -c 20)Aa1!

# Helper: arquivo de configuração temporário para evitar senha na linha de comando
_cnf() {
  local f; f=$(mktemp); chmod 600 "$f"
  printf '[client]\npassword=%s\n' "$1" > "$f"
  echo "$f"
}

# ── Configuração do bundle ────────────────────────────────────
BUNDLE_URL="https://dev.mysql.com/get/Downloads/MySQL-9.7/mysql-9.7.1-10.fc43.x86_64.rpm-bundle.tar"
BUNDLE_FILE="mysql-9.7.1-10.fc43.x86_64.rpm-bundle.tar"
RPM_DIR="/tmp/mysql-rpms"

echo "=== Instalando MySQL 9.7 via bundle RPM ==="

# ── Download do bundle ────────────────────────────────────────
mkdir -p "$RPM_DIR"
cd "$RPM_DIR"

if [ -f "$BUNDLE_FILE" ]; then
  echo "==> Bundle já baixado: $BUNDLE_FILE"
else
  echo "==> Baixando bundle MySQL 9.7.1..."
  curl -SL --progress-bar -o "$BUNDLE_FILE" "$BUNDLE_URL"
  echo "   Download concluído."
fi

# ── Extrair RPMs ──────────────────────────────────────────────
echo "==> Extraindo RPMs do bundle..."
tar xf "$BUNDLE_FILE"

# ── Instalar RPMs com dnf ─────────────────────────────────────
echo "==> Instalando pacotes MySQL..."
dnf install -y \
  "$RPM_DIR"/mysql-community-common-*.rpm \
  "$RPM_DIR"/mysql-community-client-plugins-*.rpm \
  "$RPM_DIR"/mysql-community-libs-*.rpm \
  "$RPM_DIR"/mysql-community-icu-data-files-*.rpm \
  "$RPM_DIR"/mysql-community-client-*.rpm \
  "$RPM_DIR"/mysql-community-server-*.rpm

# ── Iniciar serviço ───────────────────────────────────────────
echo "==> Iniciando MySQL..."
systemctl enable --now mysqld

# Aguardar MySQL gerar log com senha temporária
echo "==> Aguardando MySQL inicializar..."
for i in $(seq 1 30); do
  if grep -q 'temporary password' /var/log/mysqld.log 2>/dev/null; then
    break
  fi
  sleep 1
done

# ── Obter senha temporária ────────────────────────────────────
TEMP_PASS=$(grep -oP 'temporary password is generated for root@localhost: \K\S+' /var/log/mysqld.log 2>/dev/null || true)

if [ -n "${TEMP_PASS:-}" ]; then
  echo "   Senha temporária encontrada."

  # Redefinir para senha de bootstrap (satisfaz política forte, gerada em runtime)
  CNF_TEMP=$(_cnf "$TEMP_PASS")
  mysql --defaults-extra-file="$CNF_TEMP" --connect-expired-password \
    -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${BOOTSTRAP_PASS}';" 2>/dev/null || {
      # Fallback: skip-grant-tables se a política bloquear
      rm -f "$CNF_TEMP"
      systemctl stop mysqld
      mysqld --skip-grant-tables --user=mysql &>/dev/null &
      sleep 3
      mysql --no-defaults -e "FLUSH PRIVILEGES; UPDATE mysql.user SET authentication_string='' WHERE User='root' AND Host='localhost'; FLUSH PRIVILEGES;"
      pkill -9 mysqld 2>/dev/null || true
      sleep 1
      systemctl start mysqld
      sleep 3
      mysql --no-defaults -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${BOOTSTRAP_PASS}';"
    }
  rm -f "$CNF_TEMP"

  # Relaxar política e aplicar senha definitiva do .env
  CNF_BOOT=$(_cnf "$BOOTSTRAP_PASS")
  mysql --defaults-extra-file="$CNF_BOOT" -e "
    SET GLOBAL validate_password.policy = LOW;
    SET GLOBAL validate_password.length = 6;
    SET GLOBAL validate_password.mixed_case_count = 0;
    SET GLOBAL validate_password.number_count = 0;
    SET GLOBAL validate_password.special_char_count = 0;
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_PASS}';
    CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '${SQL_PASS}';
    GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
  "
  rm -f "$CNF_BOOT"
else
  echo "   Senha temporária não encontrada — MySQL pode já estar configurado."
fi

# ── Limpeza ───────────────────────────────────────────────────
rm -rf "$RPM_DIR"

echo ""
echo "========================================="
echo " MySQL 9.7.1 instalado via bundle RPM!"
echo " Serviço : mysqld"
echo " usuário : root  senha: ${MYSQL_ADMIN_PASS}"
echo " usuário : admin senha: ${MYSQL_ADMIN_PASS}"
echo "========================================="
