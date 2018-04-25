#!/bin/sh
set -e

if [ "$(ls -A config/foreman)" -o "$(ls -A config/foreman-proxy)" ]; then
	foreman-installer
fi

exec "bash"
