#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

echo "Creating user 'publicuser'..."
createuser publicuser --no-createrole --no-createdb --no-superuser -U $PGUSER
echo "Creating user 'tileuser'..."
createuser tileuser --no-createrole --no-createdb --no-superuser -U $PGUSER

# Adjust postgres config
echo "Adjusting postgres config..."
sed -E -i 's/^(max_connections\s*=\s*)[0-9]+/\1 300/' /var/lib/postgresql/data/postgresql.conf
sed -E -i 's/^(shared_buffers\s*=\s*)[0-9]+MB/\1 512MB/' /var/lib/postgresql/data/postgresql.conf

# Restart nginx
echo "Restarting nginx..."
service postgresql-10 restart

# Initialize template_postgis database. We create a template database in postgresql that will
# contain the postgis extension. This way, every time CartoDB creates a new user database it just
# clones this template database
echo "Creating database 'template_postgis'..."
createdb -T template0 -O postgres -U $PGUSER -E UTF8 template_postgis
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' \
  WHERE datname='template_postgis'"

echo "Creating extensions postgis, postgis_topology, plpythonu, crankshaft, plproxy"
psql -U $PGUSER template_postgis -c "CREATE EXTENSION postgis;"
psql -U $PGUSER template_postgis -c "CREATE EXTENSION postgis_topology;"
psql -U $PGUSER template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
psql -U $PGUSER template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
psql -U $PGUSER template_postgis -c "CREATE EXTENSION plpythonu;"
psql -U $PGUSER template_postgis -c "CREATE EXTENSION crankshaft VERSION 'dev';"
psql -U $PGUSER template_postgis -c "CREATE EXTENSION plproxy;"

# Custom extensions
psql -U $PGUSER template_postgis -c "CREATE EXTENSION tablefunc;"

# TODO: timescaledb https://docs.timescale.com/v1.3/getting-started/installation/ubuntu/installation-apt-ubuntu
# TODO: https://github.com/dhamaniasad/awesome-postgres#extensions
