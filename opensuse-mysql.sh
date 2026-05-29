#!/bin/bash
set -e
echo "=== Instalando MySQL 9.7 no openSUSE ==="
zypper addrepo https://repo.mysql.com/yum/mysql-9.7-community/suse/mysql-9.7-community.suse.repo
zypper refresh
zypper install -y mysql-community-server
systemctl enable --now mysql
TEMP_PASS=$(grep 'temporary password' /var/log/mysql/mysqld.log | tail -1 | awk '{print $NF}')
mysql --connect-expired-password -uroot -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
UNINSTALL COMPONENT 'file://component_validate_password';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
INSTALL COMPONENT 'file://component_validate_password';
FLUSH PRIVILEGES;
EOF
echo "MySQL 9.7 instalado."