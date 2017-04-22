#!/bin/bash
yum update -y
yum install mysql-server -y
chkconfig mysqld on
service mysqld start