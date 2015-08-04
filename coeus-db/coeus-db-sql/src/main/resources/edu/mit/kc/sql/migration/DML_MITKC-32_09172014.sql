update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Intellectual Property Review Maintainer'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Institutional Proposal Maintainer'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Create Proposal Log'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Institutional Proposal Viewer'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Create Temporary Proposal Log'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Modify Proposal Log'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'View Proposal Log'
and nmspc_cd = 'KC-IP'
/
update krim_role_t set kim_typ_id = (select KIM_TYP_ID from KRIM_TYP_T where nm= 'UnitHierarchy')
where role_nm = 'Modify All Dev Proposals'
and nmspc_cd = 'KC-UNT'
/