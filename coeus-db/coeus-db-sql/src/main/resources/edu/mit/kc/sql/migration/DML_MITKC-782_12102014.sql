update krim_role_t
set nmspc_cd = 'KC-UNT' , kim_typ_id = 68
where role_nm = 'Proposal Creator'
/

delete  from krim_role_mbr_attr_data_t
where role_mbr_id in ( select role_mbr_id from krim_role_mbr_t 
                              where role_id in (select role_id  from krim_role_t 
                                                  where role_nm = 'Proposal Creator')
) and kim_attr_defn_id = 48
/
commit
/
