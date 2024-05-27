#!/bin/bash
function help() {
  echo "Usage: $0 -d/--domain <domain>"
  echo "Options:"
  echo "  -d, --domain              Domain to use for the phishing site"
  echo "  -h, --help                Display this help and exit"
  exit 0
}

function usage() {
  echo "Usage: $0 -d/--domain <domain>"
  exit 1
}

SHORT_OPTS="d:"
LONG_OPTS="domain:"

PARSED=$(getopt -o $SHORT_OPTS -l $LONG_OPTS -n "$0" -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1
fi
eval set -- "${PARSED}"
while true; do
  case "$1" in
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

if [[ -z "$domain" ]]; then
  usage
fi
shift $(($OPTIND - 1))

script_dir=$(dirname $0)

rm $script_dir/../../nginx/nginx/conf.d/$domain.conf
rm -rf $script_dir/../../certbot/conf/live/$domain
