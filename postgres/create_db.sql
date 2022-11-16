\set echo all
create user :db_user with encrypted password :db_pass;
create database :db_name with owner :db_user;
alter database :db_name set timezone to 'UTC';
