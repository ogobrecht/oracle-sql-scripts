prompt - create table auth_users
declare
  v_name varchar2(30 char) := 'AUTH_USERS';
begin
  for i in (
    select v_name from dual
    minus
    select table_name from user_tables where table_name = v_name
  )
  loop
    execute immediate q'{
      create table auth_users (
        u_name            varchar2(15 char)  not null,
        u_first_name      varchar2(30 char)  ,
        u_last_name       varchar2(30 char)  ,
        u_email           varchar2(50 char)  not null,
        u_manager_u_name  varchar2(15 char)  ,
        u_active_yn       char(1)            not null,
        --
        primary key (u_name),
        unique (u_email),
        check (u_name = upper(u_name)),
        check (u_email = lower(u_email)),
        check (u_active_yn in ('Y', 'N'))
      )
    }';
  end loop;
end;
/