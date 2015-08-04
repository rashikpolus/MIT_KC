Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID) 
values ('KC-GEN','All','SAP_FEED_SPONSOR_FEED_DATE',sys_guid(),1,'CONFG','sysdate','A','system time when sponsor feed generate','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','SAP_FEED_SPONSOR_FEED_USER',sys_guid(),1,'CONFG','user','A','user who generate sponsor feed','KC')
/