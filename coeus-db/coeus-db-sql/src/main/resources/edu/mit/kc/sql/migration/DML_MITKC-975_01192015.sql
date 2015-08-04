delete from krim_role_perm_t
where role_id in (select role_id from krim_role_t where role_nm = 'User')
and perm_id in (select perm_id from krim_perm_t where nm ='Maintain System Parameter' and nmspc_cd = 'KR-SYS')
/
commit
/
