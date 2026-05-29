#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando MySQL 9.7 no Debian ==="
wget https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb
dpkg -i mysql-apt-config_0.8.33-1_all.deb
apt update
apt install -y mysql-server
systemctl enable --now mysql
TEMP_PASS=$(grep 'temporary password' /var/log/mysql/error.log | tail -1 | awk '{print $NF}')
mysql --connect-expired-password -uroot -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
UNINSTALL COMPONENT 'file://component_validate_password';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
INSTALL COMPONENT 'file://component_validate_password';
FLUSH PRIVILEGES;
EOF
echo "MySQL 9.7 instalado."