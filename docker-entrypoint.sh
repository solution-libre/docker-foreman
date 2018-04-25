#!/bin/sh
set -e

if [ "$(ls -A /etc/foreman)" -o "$(ls -A /etc/foreman-proxy)" ]; then
	foreman-installer
fi

exec "bash"
