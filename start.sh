#!/bin/bash

GERRIT_CONFIG_PATH=/home/gerrit/gerrit/etc/gerrit.config

set -e

# Either set all the variables when running the container, or
# do this to run postgres with docker:

# docker run -d --name gr-postgres postgres
# docker run -it --link gr-postgres:postgres --rm postgres sh -c 'exec createuser gerrit -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
# docker run -it --link gr-postgres:postgres --rm postgres sh -c 'exec createdb gerrit -O gerrit -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

PGUSER="${PGUSER:-gerrit}"
PGPASSWORD="${PGPASSWORD:-gerrit}"
PGDB="${PGDB:-gerrit}"

# Get these variables either from PGPORT and PGPORT, or from
# linked "pg" container.
PGPORT="${PGPORT:-$( echo "${PG_PORT_5432_TCP_PORT:-5432}" )}"
PGHOST="${PGHOST:-$( echo "${PG_PORT_5432_TCP_ADDR:-127.0.0.1}" )}"

if [[ "$CANONICAL_WEB_URL" ]]; then
    CANONICAL_WEB_URL=$( echo "$CANONICAL_WEB_URL" | sed 's/\//\\\//g')
    sed -r -i "s/(canonicalWebUrl *= *).*/\1${CANONICAL_WEB_URL}/" "$GERRIT_CONFIG_PATH"
fi


cat >> "$GERRIT_CONFIG_PATH" <<EOF
[database]
  type = POSTGRESQL
  hostname = $PGHOST
  port = $PGPORT
  database = $PGDB
  username = $PGUSER
  password = $PGPASSWORD
EOF

export JAVA_OPTIONS="-Xmx512m"
ulimit -c unlimited

java -jar /home/gerrit/gerrit.war init -d /home/gerrit/gerrit --batch

exec java -DGerritCodeReview=1 -jar /home/gerrit/gerrit.war daemon -d /home/gerrit/gerrit --console-log
