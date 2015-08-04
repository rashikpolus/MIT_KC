delete from krim_role_mbr_attr_data_t where role_mbr_id
in (
select role_mbr_id from krim_role_mbr_t where role_id in  (select role_id from KRIM_ROLE_T where kim_typ_id='KC10000') 
)
/
commit
/
delete from krim_role_mbr_t where role_id in  (select role_id from KRIM_ROLE_T where kim_typ_id='KC10000')
/
commit
/
