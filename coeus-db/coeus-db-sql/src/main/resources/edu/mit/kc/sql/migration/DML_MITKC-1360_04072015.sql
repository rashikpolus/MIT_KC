create table sap_kc_obj_cd_mapping(
  KC_OBJ_CD	varchar2(10),
  KC_OBJ_CD_DESC	varchar2(100),
  SAP_OBJ_CD	varchar2(10) 
)
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00005','Senior Personnel (Summer Months)','400005')
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00025', 'Senior Personnel (Academic Months)', '400025' )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00300' ,'Senior Personnel (Calendar Months)' ,'400300' )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00390', 'Postdocs', '400390 ' )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00350', 'Other Professionals', '400350'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00706' ,'Graduate Students (Research Assistants)', '400706'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00754', 'Undergraduate Students (UROPs, etc)', '400754'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00250' ,'Secretarial-Clerical (if charged directly)', '400250'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00001', 'Other Personnel Costs', '400001'  )
/
commit
/
