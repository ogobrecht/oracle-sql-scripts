prompt - create table map_roles_rights
declare
  v_name varchar2(30 char) := 'MAP_ROLES_RIGHTS';
begin
  for i in (
    select v_name from dual
    minus
    select table_name from user_tables where table_name = v_name
  )
  loop
    execute immediate q'{
      create table map_roles_rights (
        mrr_ro_id  integer  not null,
        mrr_ri_id  integer  not null,
        --
        primary key (mrr_ro_id, mrr_ri_id)
      )
    }';
  end loop;
end;
/
