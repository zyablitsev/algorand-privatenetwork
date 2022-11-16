\set echo all
select pg_terminate_backend(pg_stat_activity.pid)
    from pg_stat_activity
    where pg_stat_activity.datname = :'db_name'
        and pid != pg_backend_pid();
drop database :db_name;
drop user :db_user;
