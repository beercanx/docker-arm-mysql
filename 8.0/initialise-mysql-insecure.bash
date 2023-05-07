#!/usr/bin/env bash

echo 'Initializing MySQL database'
mysqld --initialize-insecure --default-time-zone=SYSTEM
echo 'MySQL database initialized'
