declare
  v_name varchar2(30 char) := 'AUTH_MAP_ROLES_TO_RIGHTS';
begin
  for i in (
    select v_name from dual
    minus
    select table_name from user_tables where table_name = v_name
  )
  loop
    execute immediate q'{
      create table auth_map_roles_to_rights (
        role_id   integer  not null,
        right_id  integer  not null,
        --
        primary key (role_id, right_id)
      )
    }';
  end loop;
end;
/
