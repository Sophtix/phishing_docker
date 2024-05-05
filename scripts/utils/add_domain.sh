#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi
cd /opt/phishing_docker
cp nginx/vhost.conf nginx/conf.d/$1.conf
sed -i "s/DOMAIN_NAME/$1/g" nginx/conf.d/$1.conf

docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d $1 --register-unsafely-without-email

sed -i 's/#//g' nginx/conf.d/$1.conf
docker compose exec nginx nginx -s reload