#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "❌ Execute com sudo"; exit 1; }

echo "=== Instalando MySQL 9.7 via tarball no Arch ==="
cd /tmp
wget https://dev.mysql.com/get/Downloads/MySQL-9.7/mysql-9.7.2-linux-glibc2.28-x86_64.tar.xz
tar xf mysql-9.7.2-linux-glibc2.28-x86_64.tar.xz
mv mysql-9.7.2-linux-glibc2.28-x86_64 /usr/local/mysql
groupadd mysql 2>/dev/null || true
useradd -r -g mysql -s /bin/false mysql 2>/dev/null || true
chown -R mysql:mysql /usr/local/mysql
mkdir -p /var/lib/mysql
chown mysql:mysql /var/lib/mysql
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/var/lib/mysql
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
systemctl enable mysql
systemctl start mysql
/usr/local/mysql/bin/mysql -uroot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'M1nh*S_3n7A';
FLUSH PRIVILEGES;
EOF
echo "export PATH=\$PATH:/usr/local/mysql/bin" >> ~/.bashrc
echo "MySQL 9.7 instalado."