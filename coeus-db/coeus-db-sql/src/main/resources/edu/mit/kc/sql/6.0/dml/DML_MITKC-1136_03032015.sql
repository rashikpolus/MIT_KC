delete from KRIM_ROLE_PERM_T
where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('PI')) and nmspc_cd ='KC-WKFLW')
and   PERM_ID in (select PERM_ID from krim_perm_t where upper(nm) like '%NEGOTIATION%')
/
delete from KRIM_ROLE_PERM_T
where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('COI')) and nmspc_cd ='KC-WKFLW')
and   PERM_ID in (select PERM_ID from krim_perm_t where upper(nm) like '%NEGOTIATION%')
/
delete from KRIM_ROLE_PERM_T
where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('KP')) and nmspc_cd ='KC-WKFLW')
and   PERM_ID in (select PERM_ID from krim_perm_t where upper(nm) like '%NEGOTIATION%')
/
commit
/
