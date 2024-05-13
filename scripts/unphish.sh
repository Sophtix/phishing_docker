#!/bin/bash

function help() {
  echo "Usage: $0 -p/--provider [ godaddy | cloudflare ] -d/--domain <domain> -s/--sender <sender>"
  echo "Options:"
  echo "  -p, --provider [ godaddy | cloudflare ] The DNS provider"
  echo "  -d, --domain <domain>      The domain of the phishing site"
  echo "  -s, --sender <sender>      The email sender. Will be appended to the domain"
  echo "  -h, --help                 Display this help and exit"
  exit 0
}

function usage() {
  echo "Usage: $0 -p/--provider [ godaddy | cloudflare ] -d/--domain <domain> -s/--sender <sender>"
  exit 1
}

SHORT_OPTS="p:d:s:h"

# Define long options for getopt (separated by :)
LONG_OPTS="provider:,domain:,sender:,help"

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

scripts_dir=$(dirname $0)
utils_dir=$scripts_dir/utils

# Check if vh is already created
if [[ -f $scripts_dir/../nginx/nginx/conf.d/$domain.conf ]]; then
  $utils_dir/remove_vhost.sh -d $domain
fi