/*

Example: Simple Deployment Script
=================================

This example deployment shows you how you can use some of the SQL scripts for
easily creating your data models. You need only the basic table definition and
the scripts handle the creation of the foreign keys and foreign key indexes and
also the renaming of the constraints and indexes.

For the foreign key creation you need to follow a naming convention - please
have a look into the description of the script itself for more details.

The options are always the same here in the called scripts. The first parameter
filters the users table for the action and defaults to `%` if omitted and the second parameter controls wheter we do a dry run or not

- first parameter (table filter):
  - A like expression (escape char is '\') to filter the affected tables
  - Example: 'CO\_%' will be expanded to table_name like 'CO\_%' escape '\'
  - If omitted, it will default to '%' (matches all tables)
- second paramater (dry run, report only):
  - If not null, the script will only report the intended work and do nothing
  - If null, the script will do the intended work
  - If omitted, it will default to `report only`

*/

set define on serveroutput on verify off feedback off linesize 120
whenever sqlerror exit sql.sqlcode rollback
timing start deployment
column date_time noprint new_val date_time
select to_char(sysdate,'yyyymmdd_hh24miss') as date_time from dual;
spool deploy_logs/&date_time._deploy.log

prompt
prompt Start Example Deployment
prompt ================================================================================
@app_backend/drop_existing_demo_tables.sql

prompt CREATE TABLES
@app_backend/tables/auth_users.sql
@app_backend/tables/auth_map_users_roles.sql
@app_backend/tables/auth_roles.sql
@app_backend/tables/auth_map_roles_rights.sql
@app_backend/tables/auth_rights.sql

@app_backend/load_initial_data.sql

@scripts/create_missing_foreign_keys.sql         "table_filter=AUTH\_%  dry_run=false"
@scripts/create_missing_foreign_key_indexes.sql  "table_filter=AUTH\_%  dry_run=false"
@scripts/unify_constraint_names.sql              "table_filter=AUTH\_%  dry_run=false"
@scripts/unify_index_names.sql                   "table_filter=AUTH\_%  dry_run=false"
@scripts/disable_foreign_key_constraints.sql     "table_filter=AUTH\_%  dry_run=false"
@scripts/sync_sequence_values_to_data.sql        "table_filter=AUTH\_%  dry_run=false"
@scripts/enable_foreign_key_constraints.sql      "table_filter=AUTH\_%  dry_run=false"

timing stop
prompt ================================================================================
prompt Done
prompt

spool off
