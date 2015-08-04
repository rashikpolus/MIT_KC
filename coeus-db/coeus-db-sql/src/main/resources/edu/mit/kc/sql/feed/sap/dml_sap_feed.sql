Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','SAP_FEED_DEVELOPMENT',sys_guid(),1,'CONFG','directory name','A','Path to generate SAP upload file for development mode','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID) 
values ('KC-GEN','All','SAP_FEED_TEST',sys_guid(),1,'CONFG','directory name','A','Path to generate SAP upload file for test mode','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','SAP_FEED_PRODUCTION',sys_guid(),1,'CONFG','directory name','A','Path to generate SAP upload file for production mode','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID) 
values ('KC-GEN','All','SAP_FEED_ROLODEX_FEED_DATE',sys_guid(),1,'CONFG','sysdate','A','system time when rolodex feed generate','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','SAP_FEED_ROLODEX_FEED_USER',sys_guid(),1,'CONFG','user','A','user who generate rolodex feed','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','SAP_FEED_CURRENT_FISCAL_YEAR',sys_guid(),1,'CONFG','2011','A','fiscal year value for SAP feed table','KC')
/
INSERT INTO TEMP_SAP_SPON_CD(SPONSOR_CODE,SPONSOR_NAME,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SPONSOR_CODE,SPONSOR_NAME,SYSDATE,USER,1,SYS_GUID() FROM ZSPONCD@coeus.kuali
/