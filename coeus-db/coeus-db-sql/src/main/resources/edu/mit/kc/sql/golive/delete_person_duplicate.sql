create table TMP_ENTITY_T as
select ENT_TYP_CD,ENTITY_ID from krim_entity_ent_typ_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_ent_typ_t 
where exists (select t.ENTITY_ID from krim_entity_ent_typ_t t 
inner join  TMP_ENTITY_T e on t.ENTITY_ID=e.ENTITY_ID and t.ENT_TYP_CD = e.ENT_TYP_CD)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_nm_id from krim_entity_nm_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_nm_t where entity_nm_id in(select entity_nm_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_afltn_id from krim_entity_afltn_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_afltn_t where entity_afltn_id in(select entity_afltn_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_addr_id from krim_entity_addr_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_addr_t where entity_addr_id in(select entity_addr_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_phone_id from krim_entity_phone_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_phone_t where entity_phone_id in(select entity_phone_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_email_id from krim_entity_email_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_email_t where entity_email_id in(select entity_email_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_emp_id from krim_entity_emp_info_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_emp_info_t where entity_emp_id in(select entity_emp_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
create table TMP_ENTITY_T as
select entity_id from krim_entity_priv_pref_t where entity_id not in(select entity_id from krim_prncpl_t)
/
delete from krim_entity_priv_pref_t where entity_id in(select entity_id from TMP_ENTITY_T)
/
drop table TMP_ENTITY_T
/
commit
/