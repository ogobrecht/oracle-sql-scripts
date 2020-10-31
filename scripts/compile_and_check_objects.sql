/*

Compile and Check Objects
=========================

Compile all invalid objects and check, if there are invalid objects left.

Options
-------

The first parameter of the script can contain a JSON object with one key:

- throw_error:
  - If true, the script will terminate with a SQL error when one or more objects are invalid
  - If false, the script will only report the invalid objects
  - If omitted, it will default to true

Examples
--------

    @compile_and_check_objects
    @compile_and_check_objects "{ throw_error: true  }"
    @compile_and_check_objects "{ throw_error: false }"

Meta
----
- Author: [Ottmar Gobrecht](https://ogobrecht.github.io)
- Script: [compile_and_check_objects.sql …](https://github.com/ogobrecht/oracle-sql-scripts/blob/master/scripts/)
- Last Update: 2020-10-29

*/

prompt COMPILE AND CHECK OBJECTS
set define on serveroutput on verify off feedback off linesize 120
variable options     varchar2(4000)
variable throw_error varchar2(100)

declare
  l_number_invalid_objects pls_integer;
  l_object_list            varchar2(4000);
  function get_number_invalid_objects return number is
  begin
    for i in (
      select count(*) as invalid_objects
      from user_objects
      where status = 'INVALID')
    loop
      return i.invalid_objects;
    end loop;
  end;
begin
  :options                 := q'[&1]';
  :throw_error             := nvl(json_value(:options, '$.throw_error'), 'true');
  l_number_invalid_objects := get_number_invalid_objects;
  if get_number_invalid_objects = 0 then
    dbms_output.put_line('- nothing to compile :-)');
  else
    dbms_output.put_line(
      '- compile ' || l_number_invalid_objects || ' invalid object'
      || case when l_number_invalid_objects != 1 then 's' end);
    dbms_utility.compile_schema(
      schema         => user,
      compile_all    => false,
      reuse_settings => true);
    l_number_invalid_objects := get_number_invalid_objects;
    if l_number_invalid_objects > 0 then
      select listagg(
                '- ' || object_type || ' ' || object_name,
                chr(10) on overflow truncate)
                within group (order by object_type, object_name)
      into   l_object_list
      from   user_objects
      where  status = 'INVALID';
      dbms_output.put_line(
        '- still ' || l_number_invalid_objects || ' invalid object'
        || case when l_number_invalid_objects > 1 then 's' end
        || ' after compilation :-(');
      if :throw_error = 'false' then
        dbms_output.put_line('- --------------------------------------------------');
        dbms_output.put_line(l_object_list);
        dbms_output.put_line('- --------------------------------------------------');
      else
        raise_application_error(
          -20000,
          chr(10)
          || '--------------------------------------------------' || chr(10)
          || l_number_invalid_objects || ' Invalid Object'
          || case when l_number_invalid_objects > 1 then 's' end
          || ' After Schema Compilation' || chr(10)
          || '--------------------------------------------------' || chr(10)
          || l_object_list || chr(10)
          || '--------------------------------------------------' || chr(10));
      end if;
    end if;
  end if;
end;
/
