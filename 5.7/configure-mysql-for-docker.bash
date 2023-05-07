#!/usr/bin/env bash

## Enable external connections
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

## Disable use of the internal host cache for faster name-to-IP resolution.
echo '' >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo '[mysqld]' >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'skip-host-cache' >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo '' >> /etc/mysql/mysql.conf.d/mysqld.cnf

## "Fix" problem where socket directory doesn't exist
mkdir /var/run/mysqld
chown mysql:mysql /var/run/mysqld
chmod 700 /var/run/mysqld
