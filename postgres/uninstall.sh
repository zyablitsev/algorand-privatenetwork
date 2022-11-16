#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pg_user=${PG_USERNAME:-"postgres"}
pg_pass=${PG_PASSWORD:-"postgres"}
pg_host=${PG_HOST:-"localhost"}
pg_port=${PG_PORT:-"5432"}
pg_dbname=${PG_DBNAME:-"indexer"}
pg_dbuser=${PG_DBUSER:-"indexer"}

PGPASSWORD=${pg_pass} \
	psql -h ${pg_host} -p ${pg_port} \
		-v db_user=${pg_dbuser} -v db_name=${pg_dbname} \
		-U ${pg_user} -d postgres -f uninstall.sql

echo "done!"
