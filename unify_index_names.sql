/*

Unify Index Names
-----------------

Unify the names of indexes in the current schema to the following naming
convention:

    <table_name>_<column_list>_<constraint_type>_IX

Each column in the column list is constructed by concatenating the character `C`
with the column id in the table. The column list is ordered by the column
position in the index. To ensure distinct constraint names we append numbers
from 1 up to 9 if needed.

Example index names:

OEHR_EMPLOYEES_C1_PK_IX
OEHR_EMPLOYEES_C4_UK_IX
OEHR_EMPLOYEES_C3_C2_IX
OEHR_EMPLOYEES_C11_FK_IX

OPTIONS

The first parameter of the script can contain two options:

- table_prefix:
  - Given value will be uppercased, a right underscore be trimmed because we need to inject a backslash
  - Example: `table_prefix=hr` will result in a filter expression `table_name like 'HR\_%' escape '\'`
  - If omitted, it will default to NULL and match then all tables
- dry_run:
  - `dry_run=true` will only report the intended work and do nothing
  - `dry_run=false` will do the intended work
  - If omitted, it will default to true

EXAMPLES

    @unify_index_names.sql "dry_run=true"
    @unify_index_names.sql "table_prefix=co  dry_run=false"

META

- Author: [Ottmar Gobrecht](https://ogobrecht.github.io)
- Script: [unify_index_names.sql …](https://github.com/ogobrecht/oracle-sql-scripts/)
- Last Update: 2020-12-31

*/

prompt UNIFY INDEX NAMES
set define on serveroutput on verify off feedback off linesize 120

declare
  v_table_prefix varchar2(100);
  v_table_filter varchar2(100);
  v_dry_run      varchar2(100);
  v_count        pls_integer := 0;
begin
  v_table_prefix := rtrim(upper(regexp_substr('&1','table_prefix=([^ ]*)',1,1,'i',1)),'_');
  v_dry_run      := nvl(lower(regexp_substr('&1','dry_run=(true|false)',1,1,'i',1)), 'true');
  if v_table_prefix is null then
    dbms_output.put_line('- for all tables');
    v_table_filter := '%';
  else
    dbms_output.put_line('- for tables prefixed with ''' || v_table_prefix || '''');
    v_table_filter := v_table_prefix || '\_%';
  end if;
  if v_dry_run = 'true' then
    dbms_output.put_line('- dry run entered');
  end if;
  for i in (
--------------------------------------------------------------------------------
with
index_column_expressions as (
  -- working with long columns: http://www.oracle-developer.net/display.php?id=430
  select
    x.index_name,
    x.table_name,
    x.column_position,
    x.column_expression -- type long :-(
  from
    xmltable('/ROWSET/ROW'
      passing (select dbms_xmlgen.getxmltype(
        q'[select * from user_ind_expressions where table_name not like 'BIN%']'
        ) from dual)
      columns
        index_name        varchar2(128 char)  path 'INDEX_NAME',
        table_name        varchar2(128 char)  path 'TABLE_NAME',
        column_position   varchar2(128 char)  path 'COLUMN_POSITION',
        column_expression varchar2(4000 char) path 'COLUMN_EXPRESSION') x
),
indexes_base as (
  select
    ui.table_name,
    ui.index_name,
    listagg(uic.column_name, ',') within group(order by uic.column_position) as column_list,
    listagg('C' || utc.column_id, '_') within group(order by uic.column_position) as column_ids,
    case when ui.uniqueness = 'UNIQUE' then 'UK' end as uniqueness
  from
    sys.user_indexes                   ui
    join sys.user_ind_columns          uic on ui.table_name = uic.table_name and ui.index_name = uic.index_name
    left join index_column_expressions ice on uic.index_name = ice.index_name and uic.column_position = ice.column_position
    left join sys.user_tab_columns     utc on ui.table_name = utc.table_name
                                           and ( uic.column_name = utc.column_name
                                                 or
                                                 instr(ice.column_expression, utc.column_name) > 0 )
  where
    ui.table_name like v_table_filter escape '\'
    and ui.table_name not like 'BIN$%'
  group by
    ui.table_name,
    ui.index_name,
    ui.uniqueness
  --order by index_name, column_list
),
constraints_pk_fk as (
  select
    uc.constraint_name,
    uc.table_name,
    replace(uc.constraint_type, 'R', 'F') || 'K' as constraint_type,
    listagg(ucc.column_name, ',') within group(order by ucc.position) as column_list
  from
    sys.user_constraints       uc
    join sys.user_cons_columns ucc on uc.constraint_name = ucc.constraint_name
  where
    constraint_type in('P','R')
    and uc.table_name not like 'BIN$%'
    and uc.table_name like v_table_filter escape '\'
  group by
    uc.table_name,
    uc.constraint_type,
    uc.constraint_name
  --order by uc.table_name, column_list
),
indexes_ as (
  select
    i.table_name,
    i.index_name,
    i.table_name || '_' || i.column_ids
      || case when c.constraint_type is not null or i.uniqueness is not null then '_' || coalesce(c.constraint_type, i.uniqueness) end
      || '_IX' as new_index_name,
    i.column_list,
    i.column_ids,
    i.uniqueness,
    c.constraint_name,
    c.constraint_type
  from indexes_base             i
    left join constraints_pk_fk c on  i.table_name  = c.table_name
                                  and i.column_list = c.column_list
),
indexes_distinct as (
select
  table_name,
  index_name,
  new_index_name ||
    case
      when lead(new_index_name, 1) over(order by new_index_name, index_name) = new_index_name then '1'
      when  lag(new_index_name, 8) over(order by new_index_name, index_name) = new_index_name then '9'
      when  lag(new_index_name, 7) over(order by new_index_name, index_name) = new_index_name then '8'
      when  lag(new_index_name, 6) over(order by new_index_name, index_name) = new_index_name then '7'
      when  lag(new_index_name, 5) over(order by new_index_name, index_name) = new_index_name then '6'
      when  lag(new_index_name, 4) over(order by new_index_name, index_name) = new_index_name then '5'
      when  lag(new_index_name, 3) over(order by new_index_name, index_name) = new_index_name then '4'
      when  lag(new_index_name, 2) over(order by new_index_name, index_name) = new_index_name then '3'
      when  lag(new_index_name, 1) over(order by new_index_name, index_name) = new_index_name then '2'
    end
  as new_index_name
from
  indexes_
)
select
  table_name,
  index_name,
  new_index_name,
  'alter index ' || index_name || ' rename to ' || new_index_name as ddl
from
  indexes_distinct
where
  new_index_name != index_name
order by
  table_name,
  new_index_name,
  index_name
--------------------------------------------------------------------------------
  ) loop
    dbms_output.put_line('- ' || i.ddl);
    if v_dry_run = 'false' then
      execute immediate i.ddl;
    end if;
    v_count := v_count + 1;
  end loop;

  dbms_output.put_line('- ' || v_count || ' index'
    || case when v_count != 1 then 'es' end || ' '
    || case when v_dry_run = 'false' then 'renamed' else 'reported' end);
end;
/
