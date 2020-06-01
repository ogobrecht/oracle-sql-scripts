prompt LOAD INITIAL DATA
set define off;

prompt - table users, 2 rows
insert into users (u_name,u_first_name,u_last_name,u_email,u_manager_u_name,u_active_yn) values ('UK007','James','Bond','james.bond@mycompany.com',null,'Y');
insert into users (u_name,u_first_name,u_last_name,u_email,u_manager_u_name,u_active_yn) values ('UK006','Mr.','Bean','mr.bean@mycompany.com',null,'Y');

prompt - table map_users_roles, 2 rows
insert into map_users_roles (mur_u_name,mur_ro_id) values ('UK007',1);
insert into map_users_roles (mur_u_name,mur_ro_id) values ('UK006',3);

prompt - table roles, 4 rows
insert into roles (ro_id,ro_name,ro_description,ro_active_yn) values (1,'ADMIN','Full app rights','Y');
insert into roles (ro_id,ro_name,ro_description,ro_active_yn) values (2,'Reader','Read access to the app','Y');
insert into roles (ro_id,ro_name,ro_description,ro_active_yn) values (3,'Contributor','Can create content','Y');
insert into roles (ro_id,ro_name,ro_description,ro_active_yn) values (4,'Editor','Can release content','Y');

prompt - table map_roles_rights, 10 rows
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (1,1);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (1,2);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (1,3);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (1,4);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (2,2);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (3,2);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (3,3);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (4,2);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (4,3);
insert into map_roles_rights (mrr_ro_id,mrr_ri_id) values (4,4);

prompt - table rights, 4 rows
insert into rights (ri_id,ri_name,ri_description,ri_active_yn) values (1,'ADMIN',null,'Y');
insert into rights (ri_id,ri_name,ri_description,ri_active_yn) values (2,'Read Content',null,'Y');
insert into rights (ri_id,ri_name,ri_description,ri_active_yn) values (3,'Create Content',null,'Y');
insert into rights (ri_id,ri_name,ri_description,ri_active_yn) values (4,'Release Content',null,'Y');

commit;