/*

Example: Simple Deployment Script
=================================

This example deployment shows you how you can use some of the SQL scripts for
easily creating your data models. You need only the basic table definitions and
the helper scripts handle the creation of the foreign keys/foreign key indices and
also the unified naming of the constraints and indices.

For the foreign key creation you need to follow a naming convention - please
have a look into the description of the script itself for more details.

The options are always the same here in the called scripts. The first parameter
filters the users table for the action and defaults to `%` if omitted and the second parameter controls wheter we do a dry run or not

- first parameter (table prefix filter):
  - Given value will be uppercased, a right underscore be trimmed because we need to inject a backslash
  - Example: `table_prefix=hr` will result in a filter expression `table_name like 'HR\_%' escape '\'`
  - If omitted, it will default to NULL and match then all tables
- second paramater (dry run flag):
  - `dry_run=true` will only report the intended work and do nothing
  - `dry_run=false` will do the intended work
  - If omitted, it will default to true

*/

set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
timing start deployment
column date_time noprint new_val date_time
select to_char(sysdate,'yyyymmdd_hh24miss') as date_time from dual;
spool deploy_logs/&date_time._deploy.log

prompt
prompt Start Example Deployment
prompt ================================================================================
@deploy_scripts/drop_existing_demo_tables

prompt CREATE TABLES
@run "demo_tables/auth_users"
@run "demo_tables/auth_map_users_to_roles"
@run "demo_tables/auth_roles"
@run "demo_tables/auth_map_roles_to_rights"
@run "demo_tables/auth_rights"

-- finish data model
@create_missing_foreign_keys         "table_prefix=auth  dry_run=false"
@create_missing_foreign_key_indexes  "table_prefix=auth  dry_run=false"
@unify_constraint_names              "table_prefix=auth  dry_run=false"
@unify_index_names                   "table_prefix=auth  dry_run=false"

-- load initial data
@disable_foreign_key_constraints     "table_prefix=auth  dry_run=false"
@deploy_scripts/load_initial_data
@sync_sequence_values_to_data        "table_prefix=auth  dry_run=false"
@enable_foreign_key_constraints      "table_prefix=auth  dry_run=false"

timing stop
prompt ================================================================================
prompt Deployment Finished
prompt

spool off
