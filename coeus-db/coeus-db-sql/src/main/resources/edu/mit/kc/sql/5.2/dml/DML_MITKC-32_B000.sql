UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Intellectual Property Review Maintainer' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Institutional Proposal Maintainer' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Institutional Proposal Viewer' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Create Proposal Log' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Create Temporary Proposal Log' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Modify Proposal Log' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'View Proposal Log' and NMSPC_CD = 'KC-IP'
/
UPDATE KRIM_ROLE_T set KIM_TYP_ID = (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-SYS' AND NM = 'UnitHierarchy') where ROLE_NM = 'Modify All Dev Proposals' and NMSPC_CD = 'KC-UNT'
/
