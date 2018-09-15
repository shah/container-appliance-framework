#! /bin/bash
set -e
echo "Entered docker-entrypoint.sh at `date`, running scripts in /docker-entrypoint-init.d"
run-parts --verbose /docker-entrypoint-init.d
if [ "$1" = 'java' ]; then
	chown -R cs_mirth /opt/mirth-connect/appdata
	exec gosu cs_mirth "$@"
fi
exec "$@"

