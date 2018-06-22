#!/bin/bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [ ! "$(ls -A /etc/foreman)" -o ! "$(ls -A /etc/foreman-proxy)" ]; then
	apt-get update
	file_env 'FOREMAN_DB_PASSWORD' 'foreman_password'
	sed -i -e "s/^  db_password:.*/  db_password: ${FOREMAN_DB_PASSWORD}/" /etc/foreman-installer/scenarios.d/foreman-answers.yaml
	mv /etc/foreman{.dist/*,/}
	mv /etc/foreman-proxy{.dist/*,/}
	rm -rf /etc/{foreman,foreman-proxy}.dist
	chown foreman: /etc/foreman /var/log/foreman
	chown foreman-proxy: /etc/foreman-proxy /var/log/foreman-proxy
	foreman-installer
	rm -rf /var/lib/apt/lists/*
fi

exec "$@"
