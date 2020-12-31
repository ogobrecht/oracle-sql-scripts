declare
  v_name varchar2(30 char) := 'AUTH_MAP_USERS_TO_ROLES';
begin
  for i in (
    select v_name from dual
    minus
    select table_name from user_tables where table_name = v_name
  )
  loop
    execute immediate q'{
      create table auth_map_users_to_roles (
        user_id  varchar2(15 char)  not null,
        role_id  integer            not null,
        --
        primary key (user_id, role_id)
      )
    }';
  end loop;
end;
/
