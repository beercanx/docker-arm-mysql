#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

## Setup the root user password
debconf-set-selections <<< "mysql-server mysql-server/root_password password password"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password password"

## Update the apt lists
apt-get update

## Install script dependencies
apt-get install -y --no-install-recommends bzip2 ca-certificates gosu openssl perl pwgen wget xz-utils zstd

## Install MySQL - mecab-ipadic fails to install on arm/v7 so its being excluded.
apt-get install -y "mysql-server-${MYSQL_MAJOR}" mecab-ipadic- mecab-ipadic-utf8- tzdata

## Clean up any mess
apt-get clean autoclean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

## Empty out the default MySQL data directory, its for our entrypoint script
rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
