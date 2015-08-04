Insert into ALERT_TYPE (ALERT_TYPE_ID,ALERT_TYPE_NAME,ALERT_TYPE_NMSPC_CD,ALERT_TYPE_SERVICE_NM,ALERT_TYPE_ACTIVE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
values (1,'CoiDisclosureExpirationAlert','COI','coiDisclosureAlertService','Y',sysdate,'admin',0,sys_guid())
/
Insert into ALERT_TYPE (ALERT_TYPE_ID,ALERT_TYPE_NAME,ALERT_TYPE_NMSPC_CD,ALERT_TYPE_SERVICE_NM,ALERT_TYPE_ACTIVE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
values (2,'AwardExpireAlert','Award','awardExpireAlertService','Y',sysdate,'admin',0,sys_guid())
/
Insert into ALERT_TYPE (ALERT_TYPE_ID,ALERT_TYPE_NAME,ALERT_TYPE_NMSPC_CD,ALERT_TYPE_SERVICE_NM,ALERT_TYPE_ACTIVE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
values (3,'FinalTechnicalReportsAlert','Award','finalTechnicalReportAlertService','Y',sysdate,'admin',0,sys_guid())
/
Insert into ALERT_TYPE (ALERT_TYPE_ID,ALERT_TYPE_NAME,ALERT_TYPE_NMSPC_CD,ALERT_TYPE_SERVICE_NM,ALERT_TYPE_ACTIVE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) 
values (4,'FinalPatentReportsAlert','Award','finalPatentReportAlertService','Y',sysdate,'admin',0,sys_guid())
/
commit
/