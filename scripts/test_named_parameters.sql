prompt TEST NAMED PARAMETERS
set define on serveroutput on verify off feedback off
variable table_prefix  varchar2(100)
variable dry_run       varchar2(100)

declare
  options varchar2(4000);
begin
  options := '&1';
  :table_prefix := json_value(options, '$.table_prefix');
  :dry_run      := json_value(options, '$.dry_run');
  dbms_output.put_line('- options: '      || options);
  dbms_output.put_line('- table_prefix: ' || :table_prefix);
  dbms_output.put_line('- dry_run: '      || :dry_run);
end;
/
