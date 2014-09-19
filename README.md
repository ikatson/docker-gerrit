# docker-gerrit

Run gerrit inside docker with postgresql, either external or dockerized.

## Quickstart. Run dockerized gerrit with dockerized postgresql.

    # Install postgres
    docker run -d --name gr-postgres postgres
    docker run -it --link gr-postgres:postgres --rm postgres sh -c 'exec createuser gerrit -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
    docker run -it --link gr-postgres:postgres --rm postgres sh -c 'exec createdb gerrit -O gerrit -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

    # Run gerrit, replace localhost:8080 with the url, which you are going to open in the browser.
    docker run -d -P --link gr-postgres:pg -e CANONICAL_WEB_URL=http://localhost:8080 ikatson/gerrit

## How to run with external (or docker host) postgres

The container accepts the following environment variables:

- ```PGHOST``` - the postgres host. Defaults to the value of ```PG_PORT_5432_TCP_ADDR```, provided by the ```pg``` linked container.
- ```PGPORT``` - the postgres port. Defaults to the value of ```PG_PORT_5432_TCP_PORT```, provided by the ```pg``` linked containe, or 5432, if it's empty.
- ```PGUSER``` - the postgres user. Defaults to ```gerrit```.
- ```PGDB``` - the postgres database name. Defaults to ```gerrit```
- ```PGPASSWORD``` - the postgres database password. Defaults to ```gerrit```

### Example. Run with postgres installed on the host machine.

    DOCKER_HOST_IP=$( ip addr | grep 'inet 172.1' | awk '{print $2}' | sed 's/\/.*//')

    docker run -d -P -e PGHOST="$DOCKER_HOST_IP" -e PGPASSWORD=123 -e PGUSER=gerrit ikatson/gerrit
