/*

Disable Foreign Key Constraints
===============================

Options
-------

The first parameter of the script can contain a JSON object with two keys:

- table_prefix:
  - If null: Takes all tables of current schema into account
  - If not null: Use the given prefix to filter tables
  - Example: "CO" will be expanded to `table_name like 'CO\_%' escape '\'`
- dry_run:
  - If null: Will do the intended script work
  - If not null: Will only report the intended script work and do nothing
  - Examples: "dry run", "test run", "do nothing", "report only" and "abc" do all the same: nothing

Usage
-----
- `@disable_all_foreign_key_constraints.sql '{ table_prefix:"",     dry_run:""     }'` (all tables, do the intended work)
- `@disable_all_foreign_key_constraints.sql '{ table_prefix:"",     dry_run:"true" }'` (all tables, report only)
- `@disable_all_foreign_key_constraints.sql '{ table_prefix:"OEHR", dry_run:""     }'` (only for tables prefixed with "OEHR")
- `@disable_all_foreign_key_constraints.sql '{ table_prefix:"CO",   dry_run:"test" }'` (only for tables prefixed with "CO", report only)

Meta
----
- Author: [Ottmar Gobrecht](https://ogobrecht.github.io)
- Script: [disable_all_foreign_key_constraints.sql](https://github.com/ogobrecht/oracle-sql-scripts/blob/master/scripts/disable_foreign_key_constraints.sql)
- Last Update: 2020-08-03

*/

prompt DISABLE FOREIGN KEY CONSTRAINTS
set define on serveroutput on verify off feedback off
variable table_prefix  varchar2(100)
variable dry_run       varchar2(100)

declare
  v_count pls_integer := 0;
  options varchar2(4000);
begin
  options := '&1';
  :table_prefix := json_value(options, '$.table_prefix');
  :dry_run      := json_value(options, '$.dry_run');
  if :table_prefix is not null then
    dbms_output.put_line('- for tables prefixed with "' || :table_prefix || '_"');
  else
    dbms_output.put_line('- for all tables');
  end if;
  if :dry_run is not null then
    dbms_output.put_line('- dry run entered');
  end if;
  for i in (
--------------------------------------------------------------------------------
select
  table_name,
  constraint_name,
  status,
  'alter table ' || table_name || ' disable constraint ' || constraint_name as ddl
from
  user_constraints
where
  table_name like case when :table_prefix is not null then :table_prefix || '\_%' else '%' end escape '\'
  and table_name not like 'BIN$%'
  and constraint_type = 'R'
  and status = 'ENABLED'
--------------------------------------------------------------------------------
  ) loop
    dbms_output.put_line('- ' || i.ddl);
    if :dry_run is null then
      execute immediate i.ddl;
    end if;
    v_count := v_count + 1;
  end loop;

  dbms_output.put_line('- ' || v_count || ' foreign key'
    || case when v_count != 1 then 's' end || ' '
    || case when :dry_run is null then 'disabled' else 'reported' end);
end;
/
