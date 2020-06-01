set define on serveroutput on verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
timing start deployment
column date_time new_val date_time
select to_char(sysdate,'yyyymmdd_hh24miss') as date_time from dual;
spool _logs/&date_time._deploy.log

prompt
prompt Start Example Deployment
prompt ================================================================================
@tables/users.sql
@tables/map_users_roles.sql
@tables/roles.sql
@tables/map_roles_rights.sql
@tables/rights.sql
@../create_missing_foreign_keys.sql ""
@../create_missing_foreign_key_indexes.sql ""
@../unify_constraint_names.sql ""
@../unify_index_names.sql ""
timing stop
prompt ================================================================================
prompt Done
prompt

spool off