#!/bin/bash
function help() {
  echo "Usage: $0 -d/--domain <domain> -p/--proxy"
  echo "Options:"
  echo "  -d, --domain              Domain to use for the phishing site"
  echo "  -p, --proxy               Use the proxy server to filter mail relays"
  echo "  -h, --help                Display this help and exit"
  exit 0
}

function usage() {
  echo "Usage: $0 -d/--domain <domain> -p/--proxy"
  exit 1
}

SHORT_OPTS="d:p"

# Define long options for getopt (separated by :)
LONG_OPTS="proxy,domain:"

PARSED=$(getopt -o $SHORT_OPTS -l $LONG_OPTS -n "$0" -- "$@")
# Check for parsing errors
if [[ $? -ne 0 ]]; then
  exit 1
fi
eval set -- "${PARSED}"
# Process arguments using getopts
while true; do
  case "$1" in
    -p | --proxy)
        proxy=true
        shift 2
        ;;
    -d | --domain)
        domain="$2"
        shift 2
        ;;
    -h | --help)
        help
        ;;
    --)
        shift
        break
        ;;
    *) 
        echo "Error: Unexpected option: $1" >&2
        exit 1
        ;;
  esac
done

if [[ -z "$domain"]]; then
  usage
fi
# Shift arguments to remove parsed options (optional)
shift $(($OPTIND - 1))

script_dir=$(dirname $0)
cd $script_dir/../..

# Check if vhost already exists
if [ -f nginx/nginx/conf.d/$domain.conf ]; then
    echo "Virtual host already exists"
    # Ask to remove the existing vhost
    read -p "Do you want to remove the existing virtual host? [y/n]: " remove_vhost
    if [ "$remove_vhost" == "y" ]; then
        $script_dir/remove_vhost.sh -d $domain
    else
        exit 1
    fi
fi

if [ -z "$proxy" ]; then
    cp nginx/vhost.conf nginx/nginx/conf.d/$domain.conf
else
    cp nginx/proxy_vhost.conf nginx/nginx/conf.d/$domain.conf
fi

sed -i "s/DOMAIN_NAME/$domain/g" nginx/nginx/conf.d/$domain.conf

docker compose run --rm certbot certonly --webroot -w /var/www/certbot/ -d $domain --register-unsafely-without-email

if [ $? -ne 0 ]; then
    echo "Failed to generate certificate"
    exit 1
fi

sed -i 's/#//g' nginx/nginx/conf.d/$domain.conf
docker compose exec nginx nginx -s reload