create schema :db_schema;
alter database :db_name set search_path to :db_schema, public, pg_catalog;
