#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../.env" ] && source "$SCRIPT_DIR/../.env"
MYSQL_ADMIN_PASS="${MYSQL_ADMIN_PASS:-DEFINA_SUA_SENHA}"

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
sleep 4

# ── Obter senha temporária ────────────────────────────────────
TEMP_PASS=$(grep -oP 'temporary password is generated for root@localhost: \K\S+' /var/log/mysqld.log 2>/dev/null || true)

if [ -n "${TEMP_PASS:-}" ]; then
  echo "   Senha temporária: $TEMP_PASS"

  # Redefinir senha root (política forte primeiro)
  mysql -u root --password="$TEMP_PASS" --connect-expired-password \
    -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Master@2026#';" 2>/dev/null || {
      # Se falhar, tenta via skip-grant-tables
      systemctl stop mysqld
      mysqld --skip-grant-tables --user=mysql &>/dev/null &
      sleep 3
      mysql --no-defaults -e "FLUSH PRIVILEGES; UPDATE mysql.user SET authentication_string='' WHERE User='root' AND Host='localhost'; FLUSH PRIVILEGES;"
      pkill -9 mysqld 2>/dev/null || true
      sleep 1
      systemctl start mysqld
      sleep 3
      mysql --no-defaults -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Master@2026#';"
    }

  # Relaxar política e aplicar senha do .env
  mysql --no-defaults --password='Master@2026#' -e "
    SET GLOBAL validate_password.policy = LOW;
    SET GLOBAL validate_password.length = 6;
    SET GLOBAL validate_password.mixed_case_count = 0;
    SET GLOBAL validate_password.number_count = 0;
    SET GLOBAL validate_password.special_char_count = 0;
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
    CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
    GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
  "
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
