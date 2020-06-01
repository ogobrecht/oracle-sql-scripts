/*

Example: Simple Deployment Script
=================================

This example deployment shows you how you can use some of the SQL scripts
for easily creating your data models. You need only the basic table definition
and the scripts handle the creation of the foreign keys and foreign key indexes
and also the renaming of the constraints and indexes.

For the foreign key creation you need to follow a naming convention - please
have a look into the description of the script itself for more details.

The parameters are always the same here in the four called scripts

Parameter 1: table prefix

- If null: Takes all tables of current schema into account
- If not null: Use the given prefix to filter tables
- Example: "CO" will be expanded to `table_name like 'CO\_%' escape '\'`

Parameter 2: dry run

- If null: Will do the intended script work
- If not null: Will only report the intended script work and do nothing
- Examples: "dry run", "test run", "do nothing", "report only" and "abc" do all the same: nothing

Drop tables:

    drop table USERS cascade constraints purge;
    drop table MAP_USERS_ROLES cascade constraints purge;
    drop table ROLES cascade constraints purge;
    drop table MAP_ROLES_RIGHTS cascade constraints purge;
    drop table RIGHTS cascade constraints purge;

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
@tables/users.sql
@tables/map_users_roles.sql
@tables/roles.sql
@tables/map_roles_rights.sql
@tables/rights.sql
@../scripts/create_missing_foreign_keys.sql "" "" --< see scripts or comment above
@../scripts/create_missing_foreign_key_indexes.sql "" "" --< for parameter descriptions
@../scripts/unify_constraint_names.sql "" ""
@../scripts/unify_index_names.sql "" ""
@../scripts/disable_foreign_key_constraints.sql "" ""
@load_initial_data.sql
@../scripts/sync_sequence_values_to_data.sql "" ""
@../scripts/enable_foreign_key_constraints.sql "" ""
timing stop
prompt ================================================================================
prompt Done
prompt

spool off