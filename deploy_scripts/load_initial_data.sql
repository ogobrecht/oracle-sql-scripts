prompt LOAD INITIAL DATA
set define off;

declare
  v_count pls_integer;
begin

  select count(*) into v_count from auth_users;
  if v_count = 0 then
    dbms_output.put_line('- table auth_users, 2 rows');
    insert into auth_users (id,first_name,last_name,email,manager_user_id,active_yn) values ('UK007','James','Bond','james.bond@mycompany.com',null,'Y');
    insert into auth_users (id,first_name,last_name,email,manager_user_id,active_yn) values ('UK006','Mr.','Bean','mr.bean@mycompany.com',null,'Y');
  else
    dbms_output.put_line('- table auth_users, 0 rows (table contains already data)');
  end if;

  select count(*) into v_count from auth_map_users_to_roles;
  if v_count = 0 then
    dbms_output.put_line('- table auth_map_users_to_roles, 2 rows');
    insert into auth_map_users_to_roles (user_id,role_id) values ('UK007',1);
    insert into auth_map_users_to_roles (user_id,role_id) values ('UK006',3);
  else
    dbms_output.put_line('- table auth_map_users_to_roles, 0 rows (table contains already data)');
  end if;

  select count(*) into v_count from auth_roles;
  if v_count = 0 then
    dbms_output.put_line('- table auth_roles, 4 rows');
    insert into auth_roles (id,name,description,active_yn) values (1,'ADMIN','Full app rights','Y');
    insert into auth_roles (id,name,description,active_yn) values (2,'Reader','Read access to the app','Y');
    insert into auth_roles (id,name,description,active_yn) values (3,'Contributor','Can create content','Y');
    insert into auth_roles (id,name,description,active_yn) values (4,'Editor','Can release content','Y');
  else
    dbms_output.put_line('- table auth_roles, 0 rows (table contains already data)');
  end if;

  select count(*) into v_count from auth_map_roles_to_rights;
  if v_count = 0 then
    dbms_output.put_line('- table auth_map_roles_to_rights, 10 rows');
    insert into auth_map_roles_to_rights (role_id,right_id) values (1,1);
    insert into auth_map_roles_to_rights (role_id,right_id) values (1,2);
    insert into auth_map_roles_to_rights (role_id,right_id) values (1,3);
    insert into auth_map_roles_to_rights (role_id,right_id) values (1,4);
    insert into auth_map_roles_to_rights (role_id,right_id) values (2,2);
    insert into auth_map_roles_to_rights (role_id,right_id) values (3,2);
    insert into auth_map_roles_to_rights (role_id,right_id) values (3,3);
    insert into auth_map_roles_to_rights (role_id,right_id) values (4,2);
    insert into auth_map_roles_to_rights (role_id,right_id) values (4,3);
    insert into auth_map_roles_to_rights (role_id,right_id) values (4,4);
  else
    dbms_output.put_line('- table auth_map_roles_to_rights, 0 rows (table contains already data)');
  end if;

  select count(*) into v_count from auth_rights;
  if v_count = 0 then
    dbms_output.put_line('- table auth_rights, 4 rows');
    insert into auth_rights (id,name,description,active_yn) values (1,'ADMIN',null,'Y');
    insert into auth_rights (id,name,description,active_yn) values (2,'Read Content',null,'Y');
    insert into auth_rights (id,name,description,active_yn) values (3,'Create Content',null,'Y');
    insert into auth_rights (id,name,description,active_yn) values (4,'Release Content',null,'Y');
  else
    dbms_output.put_line('- table auth_rights, 0 rows (table contains already data)');
  end if;

  commit;

end;
/