#!/bin/bash
script_dir=$(dirname $0)
cd $script_dir/../..
docker compose exec nginx nginx -s reload