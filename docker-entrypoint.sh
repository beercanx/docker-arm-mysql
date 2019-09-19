#!/bin/bash
set -eo pipefail

## if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
  set -- mysqld "$@"
fi

## skip setup if they want an option that stops mysqld
wantHelp=
for arg; do
  case "$arg" in
    -'?'|--help|--print-defaults|-V|--version)
      wantHelp=1
      break
      ;;
  esac
done

## Skip if want help has been flagged
if [ "$1" = 'mysqld' -a -z "${wantHelp}" ]; then

  ## Find the MySQL data directory
  DATA_DIR="$("$@" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"

  ALREADY_CONFIGURED_FILE="${DATA_DIR}/.has_already_configured_mysql"

  ## Only run if the ALREADY_CONFIGURED_FILE is not present
  if [ ! -f "${ALREADY_CONFIGURED_FILE}" ]; then

    ## Enforce configuration requirements
    if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
      echo >&2 'error: database is uninitialized and password option is not specified '
      echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD'
      exit 1
    fi

    ## Have we externalised the data mount?
    if [ ! -d "${DATA_DIR}/mysql" ]; then

        ## Just to be safe make sure it exists
        mkdir -p "${DATA_DIR}"

        ## Make sure the data directory exists and is owned by MySQL
        chown -R mysql:mysql "${DATA_DIR}"

        ## Doing this again, as we added it to the build phase to help speed up some things.
        echo 'Initializing MySQL database'
        mysqld --initialize-insecure
        echo 'MySQL database initialized'
    fi

    ## Start the MySQL daemon
    "$@" --skip-networking &
    pid="$!"

    ## MySQL command
    mysql=( mysql --protocol=socket -uroot )

    ## Wait until MySQL has started up
    for i in {30..0}; do
      if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
        break
      fi
      echo 'MySQL init process in progress...'
      sleep 1
    done
    if [ "$i" = 0 ]; then

      ## Dump the MySQL error logs if they exist
      [ -f /var/log/mysql/error.log ] && cat >&2 /var/log/mysql/error.log

      echo >&2 'MySQL init process failed.'
      exit 1
    fi

    ## Load timezones into MySQL
    if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
      echo 'Loading timezones into MySQL'
      # sed is for https://bugs.mysql.com/bug.php?id=20545
      mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql
    fi

    ## Generate a random password for root if required
    if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
      MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
      echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
    fi

    ## Set the password for root
    echo 'Setting password for root'
    "${mysql[@]}" <<< "
      -- What's done in this file shouldn't be replicated
      --  or products like mysql-fabric won't work
      SET @@SESSION.SQL_LOG_BIN=0;

      DELETE FROM mysql.user ;
      CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
      GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
      DROP DATABASE IF EXISTS test ;
      FLUSH PRIVILEGES ;
    "

    ## Update command with root password if set
    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then

      ## Update the MySQL command with root password
      mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
    fi

    ## Create database if specified
    if [ "$MYSQL_DATABASE" ]; then
      echo "Creating database: ${MYSQL_DATABASE}"

      echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"

      ## Update the MySQL command with database
      mysql+=( "$MYSQL_DATABASE" )
    fi

    ## Create database user if specified
    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
      echo "Creating user: ${MYSQL_USER}"
      echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"

      if [ "$MYSQL_DATABASE" ]; then
        echo "Granting permissions for user: ${MYSQL_USER} on: ${MYSQL_DATABASE}"
        echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
      fi

      echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
    fi

    ## If this is doing what I think, it enables running provision scripts
    echo
    for f in /docker-entrypoint-initdb.d/*; do
      case "$f" in
        *.sh)     echo "$0: running $f"; . "$f" ;;
        *.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
        *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
        *)        echo "$0: ignoring $f" ;;
      esac
      echo
    done

    ## I think its expires the root password or turns it into a one time use paassword.
    if [ ! -z "$MYSQL_ONETIME_PASSWORD" ]; then
      echo 'Setting root password as one time use'
      "${mysql[@]}" <<< "ALTER USER 'root'@'%' PASSWORD EXPIRE;"
    fi

    ## Stop the MySQL daemon we started to do the extra configuration
    if ! kill -s TERM "$pid" || ! wait "$pid"; then
      echo >&2 'MySQL init process failed.'
      exit 1
    fi

    ## Create the already configured file, as we've just configured MySQL
    touch "${ALREADY_CONFIGURED_FILE}"

    echo
    echo 'MySQL init process done. Ready for start up.'
    echo

  else

    ## Provide some useful start up logging
    echo
    echo 'MySQL is already configured, skipping any setup.'
    echo
  fi

  ## Make sure the mysql user owns the data directory
  chown -R mysql:mysql "${DATA_DIR}"
fi

## Run the passed in command
exec "$@"
