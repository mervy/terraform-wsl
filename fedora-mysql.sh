#!/bin/bash
set -e
echo "=== Instalando MySQL 9.7 no Fedora ==="
dnf install -y https://dev.mysql.com/get/mysql84-community-release-fc$(rpm -E %fedora).noarch.rpm
dnf install -y mysql-community-server
systemctl enable --now mysqld
TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
mysql --connect-expired-password -uroot -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
UNINSTALL COMPONENT 'file://component_validate_password';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
INSTALL COMPONENT 'file://component_validate_password';
FLUSH PRIVILEGES;
EOF
echo "MySQL 9.7 instalado e senha root configurada."