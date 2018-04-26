#!/bin/sh
set -e

if [ ! "$(ls -A /etc/foreman)" -o ! "$(ls -A /etc/foreman-proxy)" ]; then
	apt-get update
	foreman-installer
	rm -rf /var/lib/apt/lists/*
fi

exec "$@"
