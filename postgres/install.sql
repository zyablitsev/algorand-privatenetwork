\set echo all
\qecho 'installing db schema'

set statement_timeout = 0;
set lock_timeout = 0;
set client_encoding = 'UTF8';
set standard_conforming_strings = on;
set check_function_bodies = false;
set client_min_messages = warning;
set row_security = off;


begin;

\i schema.sql

commit;

\qecho 'done.'
