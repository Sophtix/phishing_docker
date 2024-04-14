#!/bin/bash

# Build images and create containers
docker compose up --build -d

# Generate certificats for admin servers
docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d gophish.live --register-unsafely-without-email
docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d evil.gophish.live --register-unsafely-without-email

# Activate https for admin servers
sudo sed 's/#//g' nginx/conf.d/default.conf
docker compose exec nginx nginx -s reload