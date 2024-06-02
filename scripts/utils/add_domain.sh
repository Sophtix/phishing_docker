#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

script_dir=$(dirname $0)
pushd $script_dir/../..

cp nginx/vhost.conf nginx/nginx/conf.d/$1.conf
sed -i "s/DOMAIN_NAME/$1/g" nginx/nginx/conf.d/$1.conf

docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d $1 --register-unsafely-without-email

sed -i 's/#//g' nginx/nginx/conf.d/$1.conf
docker compose exec nginx nginx -s reload

popd
