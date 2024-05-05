#!/bin/bash
SHORT_OPTS="p:d:s:"

# Define long options for getopt (separated by :)
LONG_OPTS="provider:,domain:,sender:"

PARSED=$(getopt -o $SHORT_OPTS -l $LONG_OPTS -n "$0" -- "$@")
# Check for parsing errors
if [[ $? -ne 0 ]]; then
  exit 1
fi
eval set -- "${PARSED}"
provider=n domain=n sender=n
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
  echo "Error: Missing required arguments. Please provide -p/--provider, -d/--domain, and -s/--sender." >&2
  exit 1
fi
# Shift arguments to remove parsed options (optional)
shift $(($OPTIND - 1))

scripts_dir=$(dirname $0)
utils_dir=$scripts_dir/utils
python3 $utils_dir/infrastructure.py -p $provider -d $domain -s $sender
bash $utils_dir/add_domain.sh $domain