#!/bin/bash

# login credentials for cartodb user that will be created
DEFAULT_USER=${DEFAULT_USER:-username}
SUBDOMAIN=${DEFAULT_USER:-username}
PASSWORD=${PASSWORD:-password}
EMAIL=${EMAIL:-username@example.com}
ORGANIZATION_NAME=${ORGANIZATION_NAME:-organization}
export ORGANIZATION_NAME=$ORGANIZATION_NAME
GDRIVE_OAUTH_CLIENT_ID=${GDRIVE_OAUTH_CLIENT_ID:-client_id}
GDRIVE_OAUTH_CLIENT_SECRET=${GDRIVE_OAUTH_CLIENT_SECRET:-client_secret}

# Server config
REDIS_SERVER=${REDIS_SERVER:-127.0.0.1}
COVERBAND_REDIS_URL="redis://${REDIS_SERVER}:6379"
export COVERBAND_REDIS_URL="redis://${REDIS_SERVER}:6379"

# host and port on which the app will be exposed
PUBLIC_HOST=${PUBLIC_HOST:-localhost}
PUBLIC_PORT=${PUBLIC_PORT:-80}
PUBLIC_PROTOCOL=${PUBLIC_PROTOCOL:-http}

echo "Writing the configuration files..."
  DEFAULT_USER=$DEFAULT_USER \
  POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  PUBLIC_HOST=$PUBLIC_HOST \
  PUBLIC_PORT=$PUBLIC_PORT \
  PUBLIC_PROTOCOL=$PUBLIC_PROTOCOL \
  SUBDOMAIN=$SUBDOMAIN \
  GDRIVE_OAUTH_CLIENT_ID=$GDRIVE_OAUTH_CLIENT_ID \
  GDRIVE_OAUTH_CLIENT_SECRET=$GDRIVE_OAUTH_CLIENT_SECRET \
  node docker-entrypoint-util/configure $@

echo "Restoring user metadata"
bundle exec ./script/restore_redis

echo "Starting resque process"
#bundle exec ./script/resque &
bundle exec ./script/resque > resque.log 2>&1 &

echo "Initializing the metadata database..."
echo "Running db:create..."
bundle exec rake db:create
echo "Running db:migrate..."
bundle exec rake db:migrate

echo "Creating default user"
script/create_dev_user "$SUBDOMAIN" "$PASSWORD" "$EMAIL"

echo "Enable features"
bundle exec rake cartodb:features:add_feature_flag["carto-connectors"]
bundle exec rake cartodb:features:enable_feature_for_all_users["carto-connectors"]
bundle exec rake cartodb:features:enable_feature_for_all_users["new_dashboard"]

echo "Add organization ${ORGANIZATION_NAME}"
bundle exec rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="${ORGANIZATION_NAME}" USERNAME="${SUBDOMAIN}" ORGANIZATION_SEATS=100 ORGANIZATION_QUOTA=102400 ORGANIZATION_DISPLAY_NAME="${ORGANIZATION_NAME}"
bundle exec rake cartodb:db:set_organization_quota["${ORGANIZATION_NAME}",50000] --trace
bundle exec rake cartodb:db:configure_geocoder_extension_for_organizations["${ORGANIZATION_NAME}"] --trace

echo "Set geocoding quota"
bundle exec rake cartodb:services:set_org_quota[$ORGANIZATION_NAME,"geocoding",100000]
bundle exec rake cartodb:services:set_user_quota[$SUBDOMAIN,"geocoding",100000]

echo "Starting the application..."
exec bundle exec rails server -b 0.0.0.0
