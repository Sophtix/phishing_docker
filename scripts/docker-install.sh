#!/bin/bash
scripts_dir=$(dirname $(realpath $0))
cd $scripts_dir/..

# Build images and create containers
docker compose up --build -d

# Generate certificats for admin servers
docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d gophish.co --register-unsafely-without-email
if [ $? -ne 0 ]; then
    echo "Error while generating certificats for gophish.co"
    exit 1
fi

docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d evil.gophish.co --register-unsafely-without-email
if [ $? -ne 0 ]; then
    echo "Error while generating certificats for evil.gophish.co"
    exit 1
fi

# Activate https for admin servers
sed -i 's/#//g' ./nginx/nginx/conf.d/default.conf
docker compose exec nginx nginx -s reload