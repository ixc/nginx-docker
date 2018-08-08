#!/bin/bash

set -e

mkdir -p /opt/nginx/run

# Generate htpasswd file if credentials are set.
if [[ -n "$NGINX_BASIC_AUTH" ]]; then
	# Split on `:`.
	IFS=: read BASIC_AUTH_USERNAME BASIC_AUTH_PASSWORD <<< "$NGINX_BASIC_AUTH"
	echo "$BASIC_AUTH_PASSWORD" | htpasswd -ci /opt/nginx/etc/nginx.htpasswd "$BASIC_AUTH_USERNAME"
fi

# Render nginx config template.
dockerize -template /opt/nginx/etc/nginx.tmpl.conf:/opt/nginx/etc/nginx.conf

# Set `error_log` via command line to avoid a permissions error when run as an
# unprivileged user. See: https://stackoverflow.com/a/24423319
exec nginx -c /opt/nginx/etc/nginx.conf -g "error_log /dev/stderr;" "$@"
