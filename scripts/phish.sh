#!/bin/bash

function help() {
  echo "Usage: $0 -p/--provider [ godaddy | cloudflare ] -d/--domain <domain> -s/--sender <sender> [-x/--proxy] [-h/--help]"
  echo "Options:"
  echo "  -p, --provider [ godaddy | cloudflare ] The DNS provider"
  echo "  -d, --domain <domain>      The domain to use for the phishing site"
  echo "  -s, --sender <sender>      The email sender. Will be appended to the domain"
  echo "  -x, --proxy                Use the proxy server to filter mail relays"
  echo "  -h, --help                 Display this help and exit"
  echo "Example:"
  echo "  create a phishing site for example.com using godaddy as the DNS provider and admin@example.com as the sender:"
  echo "  $0 -p godaddy -d example.com -s admin"
  exit 0
}

function usage() {
  echo "Usage: $0 -p/--provider [ godaddy | cloudflare ] -d/--domain <domain> -s/--sender <sender> [-x/--proxy] [-h/--help]"
  exit 1
}

SHORT_OPTS="p:d:s:hx"

# Define long options for getopt (separated by :)
LONG_OPTS="provider:,domain:,sender:,help,proxy"

PARSED=$(getopt -o $SHORT_OPTS -l $LONG_OPTS -n "$0" -- "$@")
# Check for parsing errors
if [[ $? -ne 0 ]]; then
  exit 1
fi
eval set -- "${PARSED}"
# Process arguments using getopts
while true; do
  case "$1" in
    -p | --provider)
        provider="$2"
        shift 2
        ;;
    -d | --domain)
        domain="$2"
        shift 2
        ;;
    -s | --sender)
        sender="$2"
        shift 2
        ;;
    -x | --proxy)
        proxy=true
        shift
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

if [[ -z "$provider" || -z "$domain" || -z "$sender" ]]; then
  usage
fi
# Shift arguments to remove parsed options (optional)
shift $(($OPTIND - 1))

scripts_dir=$(dirname $(realpath $0))
utils_dir=$scripts_dir/utils
python3 $utils_dir/infrastructure.py -p $provider -d $domain -s $sender

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to prepearing infrastructure, see output for details" >&2
  exit 1
fi

if [ "$proxy" = true ]; then
  /bin/bash $utils_dir/add_vhost.sh -d $domain -p
  exit 0
else
  /bin/bash $utils_dir/add_vhost.sh -d $domain
  exit 0
fi