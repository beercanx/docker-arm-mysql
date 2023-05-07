#!/usr/bin/env bash

## Enable external connections
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

## Disable use of the internal host cache for faster name-to-IP resolution.
{
  echo ''
  echo '[mysqld]'
  echo 'skip-host-cache'
  echo 'skip-name-resolve'
  echo ''
} >> /etc/mysql/mysql.conf.d/docker.cnf

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 1777 /var/run/mysqld /var/lib/mysql
