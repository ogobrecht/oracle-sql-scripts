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
        id               varchar2(15 char)  not null,
        first_name       varchar2(30 char)  ,
        last_name        varchar2(30 char)  ,
        email            varchar2(50 char)  not null,
        manager_user_id  varchar2(15 char)  ,
        active_yn        char(1)            not null,
        --
        primary key (id),
        unique (email),
        check (id = upper(id)),
        check (email = lower(email)),
        check (active_yn in ('Y', 'N'))
      )
    }';
  end loop;
end;
/
