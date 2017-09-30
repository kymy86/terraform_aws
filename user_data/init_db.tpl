#!/bin/bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

while ! mysqladmin ping -u${db_user} -p${db_pass} -h${db_dns} --silent; do
    sleep 1
done

sudo mysql -u${db_user} -p${db_pass} -h${db_dns} </tmp/init-db.sql

sudo rm -rf /tmp/init-db.sql