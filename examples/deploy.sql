/*

Example: Simple Deployment Script
=================================

This example deployment shows you how you can use some of the SQL scripts
for easily creating your data models. You need only the basic table definition
and the scripts handle the creation of the foreign keys and foreign key indexes
and also the renaming of the constraints and indexes.

For the foreign key creation you need to follow a naming convention - please
have a look into the description of the script itself for more details.

The options are always the same here in the four called scripts. The first
parameter of the script can contain a JSON object with two keys:

- table_prefix:
  - If null: Takes all tables of current schema into account
  - If not null: Use the given prefix to filter tables
  - Example: "CO" will be expanded to `table_name like 'CO\_%' escape '\'`
- dry_run:
  - If true: Will do the intended script work
  - If false: Will only report the intended script work and do nothing

*/

set define on serveroutput on verify off feedback off linesize 200
whenever sqlerror exit sql.sqlcode rollback
timing start deployment
column date_time noprint new_val date_time
select to_char(sysdate,'yyyymmdd_hh24miss') as date_time from dual;
spool logs/&date_time._deploy.log

prompt
prompt Start Example Deployment
prompt ================================================================================
--@tables/drop_existing_demo_tables.sql

prompt CREATE TABLES
@tables/users.sql
@tables/map_users_roles.sql
@tables/roles.sql
@tables/map_roles_rights.sql
@tables/rights.sql

@../scripts/create_missing_foreign_keys.sql        '{ table_prefix:"", dry_run: false }'
@../scripts/create_missing_foreign_key_indexes.sql '{ table_prefix:"", dry_run: false }'
@../scripts/unify_constraint_names.sql             '{ table_prefix:"", dry_run: false }'
@../scripts/unify_index_names.sql                  '{ table_prefix:"", dry_run: false }'
@../scripts/disable_foreign_key_constraints.sql    '{ table_prefix:"", dry_run: false }'
@load_initial_data.sql
@../scripts/sync_sequence_values_to_data.sql       '{ table_prefix:"", dry_run: false }'
@../scripts/enable_foreign_key_constraints.sql     '{ table_prefix:"", dry_run: false }'

timing stop
prompt ================================================================================
prompt Done
prompt

spool off
