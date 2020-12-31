prompt DROP EXISTING DEMO TABLES
declare
  v_count pls_integer := 0;
  v_ddl   varchar2(1000);
begin
  for i in (
    select *
      from user_tables
     where table_name in (
             'AUTH_USERS',
             'AUTH_MAP_USERS_TO_ROLES',
             'AUTH_ROLES',
             'AUTH_MAP_ROLES_TO_RIGHTS',
             'AUTH_RIGHTS'
           )
  ) loop
    v_ddl := 'drop table ' || i.table_name || ' cascade constraints purge';
    dbms_output.put_line(' - ' || v_ddl);
    execute immediate v_ddl;
    v_count := v_count + 1;
  end loop;
  if v_count = 0 then
    dbms_output.put_line(' - no tables to drop');
  else
    dbms_output.put_line('- ' || v_count || ' table'
      || case when v_count != 1 then 's' end || ' dropped');
  end if;
end;
/
