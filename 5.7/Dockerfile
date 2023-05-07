FROM ubuntu:xenial

USER root

## Create mysql user early to keep UID/GUID consistent
RUN groupadd -r mysql && useradd -r -g mysql mysql

## Set the mysql version to install
ENV MYSQL_MAJOR 5.7

## Upload MySQL install script
COPY install-mysql.bash /opt/docker-arm-mysql/

## Install MySQL
RUN /opt/docker-arm-mysql/install-mysql.bash

## Upload MySQL configuration for docker script
COPY configure-mysql-for-docker.bash /opt/docker-arm-mysql/

## Run MySQL configuration for docker script
RUN /opt/docker-arm-mysql/configure-mysql-for-docker.bash

## Upload script to initialise MySQL
COPY initialise-mysql-insecure.bash /opt/docker-arm-mysql/

## Run script to initialize MySQL
RUN /opt/docker-arm-mysql/initialise-mysql-insecure.bash

## Setup MySQL data directory as a volume
VOLUME /var/lib/mysql

## Create the init folder for sql files to import at first start up
RUN mkdir /docker-entrypoint-initdb.d

## Upload docker entrypoint script
COPY docker-entrypoint.sh /opt/docker-arm-mysql/

## Set the entrypoint script, used to configure depending on requirements.
ENTRYPOINT ["/opt/docker-arm-mysql/docker-entrypoint.sh"]

## Expose the MySQL port
EXPOSE 3306

## Set the default command to be the MySQL daemon
CMD ["mysqld"]
