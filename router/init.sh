#!/bin/bash -e
if [[ -z "${EMAIL}" ]]
then
  echo "EMAIL needs to be set"
  exit 1
fi

if [[ -z "${DOMAIN}" ]]
then
  echo "DOMAIN needs to be set"
  exit 1
fi

# Copy templates to production
envsubst_nginx="envsubst '"'${DOMAIN},${SERVER}'"'"

# Creating directories
WEBROOT_PATH="/var/www/html"
mkdir -p ${WEBROOT_PATH}/.well-known/acme-challenge

echo "Restarting nginx..."
service nginx restart
sleep 20

# Issue certificates
# TODO: rewrite this mess
if [ -d /etc/letsencrypt/live ]; then
  echo "Directory with certificates found"
  certbot certonly \
    --non-interactive \
    --webroot \
    -w "${WEBROOT_PATH}" \
    -m "${EMAIL}" \
    -q \
    --agree-tos \
    --expand \
    --rsa-key-size 4096 \
    --preferred-challenges http \
    -d "${DOMAIN}"
else
  certbot certonly \
    --non-interactive \
    --webroot \
    -w "${WEBROOT_PATH}" \
    -m "${EMAIL}" \
    -q \
    --agree-tos \
    --rsa-key-size 4096 \
    --preferred-challenges http \
    -d "${DOMAIN}"
fi

sleep 10

$envsubst_nginx < /etc/nginx/ssl.conf.tmpl > /etc/nginx/ssl.conf
$envsubst_nginx < /etc/nginx/server.conf.tmpl > /etc/nginx/site.d/${DOMAIN}.conf

# dhparam
openssl dhparam -dsaparam -out /etc/letsencrypt/dhparam.pem 4096 # > /dev/null 2>&1 &

# restart and wait for nginx to boot
echo "Restarting nginx again..."
service nginx restart
sleep 10

# Modify worker_processes config var
NUMPROCS=$(nproc)
sed -i "s/worker_processes\s\+1;/worker_processes ${NUMPROCS};/" /etc/nginx/nginx.conf

service nginx stop
exec nginx -g "daemon off;"
