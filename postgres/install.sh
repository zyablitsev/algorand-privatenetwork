#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pg_user=${PG_USERNAME:-"postgres"}
pg_pass=${PG_PASSWORD:-"postgres"}
pg_host=${PG_HOST:-"localhost"}
pg_port=${PG_PORT:-"5432"}
pg_dbname=${PG_DBNAME:-"indexer"}
pg_dbschema=${PG_DBSCHEMA:-"indexer"}
pg_dbuser=${PG_DBUSER:-"indexer"}
pg_dbpass=${PG_DBPASS:-"indexer"}

echo "creating database."
PGUSER=${pg_user} PGPASSWORD=${pg_pass} \
	psql -h ${pg_host} -p ${pg_port} \
		-v db_user=${pg_dbuser} -v db_pass="'${pg_dbpass}'" -v db_name=${pg_dbname} \
		-d postgres -f create_db.sql

echo "creating schema."
PGUSER=${pg_dbuser} PGPASSWORD=${pg_dbpass} \
	psql -h ${pg_host} -p ${pg_port} \
		-v db_name=${pg_dbname} -v db_schema=${pg_dbschema} \
		-d ${pg_dbname} -f install.sql

echo "done!"
