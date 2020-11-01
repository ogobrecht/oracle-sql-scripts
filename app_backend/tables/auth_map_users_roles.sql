prompt - create table auth_map_users_roles
declare
  v_name varchar2(30 char) := 'AUTH_MAP_USERS_ROLES';
begin
  for i in (
    select v_name from dual
    minus
    select table_name from user_tables where table_name = v_name
  )
  loop
    execute immediate q'{
      create table auth_map_users_roles (
        mur_u_name  varchar2(15 char)  not null,
        mur_ro_id   integer            not null,
        --
        primary key (mur_u_name, mur_ro_id)
      )
    }';
  end loop;
end;
/
