#!/bin/bash
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get install mysql-client -y

cat <<'EOF' >/tmp/init-db.sql
GRANT ALL ON ${db_name}.* TO '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
FLUSH PRIVILEGES;
EOF

while ! mysqladmin ping -h${db_dns} --silent; do
    sleep 3
done

sudo mysql -u${db_user} -p${db_pass} -h${db_dns} </tmp/init-db.sql

sudo rm -rf /tmp/init-db.sql
