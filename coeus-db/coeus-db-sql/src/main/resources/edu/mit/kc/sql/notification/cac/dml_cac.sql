set define off
/
INSERT INTO COEUS_MODULE(
MODULE_CODE,
DESCRIPTION,
UPDATE_TIMESTAMP,
UPDATE_USER,
VER_NBR,
OBJ_ID)
VALUES(
200,
'CAC',
sysdate,
user,
1,
sys_guid()
)
/
INSERT INTO NOTIFICATION_TYPE(
NOTIFICATION_TYPE_ID,
MODULE_CODE,
ACTION_CODE,
DESCRIPTION,
SUBJECT,
MESSAGE,
PROMPT_USER,
SEND_NOTIFICATION,
UPDATE_USER,
UPDATE_TIMESTAMP,
VER_NBR,
OBJ_ID)
VALUES(SEQ_NOTIFICATION_TYPE_ID.NEXTVAL,
200,
'501',
'CAC - Update Special Review Animal Protocols with data from CAC, send email to CACPO@mit.edu',
'CAC Notifications -- to CAC',
' <table border="1">
                <tr>
                <th>PROTOCOL NUMBER</th>
                <th>WBS NUMBER</th>
                <th>COMMENTS</th>
               </tr>
               {list} </table>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
INSERT INTO NOTIFICATION_TYPE(
NOTIFICATION_TYPE_ID,
MODULE_CODE,
ACTION_CODE,
DESCRIPTION,
SUBJECT,
MESSAGE,
PROMPT_USER,
SEND_NOTIFICATION,
UPDATE_USER,
UPDATE_TIMESTAMP,
VER_NBR,
OBJ_ID)
VALUES(SEQ_NOTIFICATION_TYPE_ID.NEXTVAL,
200,
'502',
'CAC - Update Special Review Animal Protocols with data from CAC, send email to coeus-data@mit.edu',
'CAC Notifications -- to OSP',
' <table border="1">
                <tr>
                <th>PROTOCOL NUMBER</th>
                <th>AWARD/IP NUMBER</th>
                <th>WBS NUMBER</th>
                <th>COMMENTS</th>
                <th>CAC APPROVAL DATE</th>
               </tr>
               {list} </table>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/

INSERT INTO NOTIFICATION_TYPE(
NOTIFICATION_TYPE_ID,
MODULE_CODE,
ACTION_CODE,
DESCRIPTION,
SUBJECT,
MESSAGE,
PROMPT_USER,
SEND_NOTIFICATION,
UPDATE_USER,
UPDATE_TIMESTAMP,
VER_NBR,
OBJ_ID)
VALUES(SEQ_NOTIFICATION_TYPE_ID.NEXTVAL,
200,
'503',
'CAC - Update Special Review Animal Protocols with data from CAC, send email to coeus-data@mit.edu',
'CAC Notification No Data -- to OSP',
'There is no CAC data to process.',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
INSERT INTO NOTIFICATION_TYPE(
NOTIFICATION_TYPE_ID,
MODULE_CODE,
ACTION_CODE,
DESCRIPTION,
SUBJECT,
MESSAGE,
PROMPT_USER,
SEND_NOTIFICATION,
UPDATE_USER,
UPDATE_TIMESTAMP,
VER_NBR,
OBJ_ID)
VALUES(SEQ_NOTIFICATION_TYPE_ID.NEXTVAL,
200,
'504',
'CAC - daily dataload completion Notification',
'Load CAC Data',
' CAC daily dataload completed.',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
delete from kc_qrtz_cron_triggers where trigger_name='cacDataFeedTrigger'
/
delete from kc_qrtz_triggers where trigger_name='cacDataFeedTrigger'
/
delete from kc_qrtz_job_details where job_name='cacDataFeedJobDetail'
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) 
	values ('KC-ADM','All','CAC_DATA_FEED_CRON_TRIGGER',SYS_GUID(),1,'CONFG','0 5 7 * * ?','Cron expression for CAC feed','A','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) 
	values ('KC-ADM','All','ENABLE_CAC_DATA_FEED',SYS_GUID(),1,'CONFG','Y','CAC feed enable flag','A','KC')
/
commit
/
insert into cac_data(
                  CAC_DATA_ID,
                  APPROVAL_DATE             ,
                  CONTACT_EMAIL             ,
                  DEPT                      ,
                  EXPIRATION_DATE           ,
                  FUNDING_AGENCY            ,
                  FUNDING_AGENCY2           ,
                  FUNDING_AGENCY3           ,
                  FUNDING_AGENCY4           ,
                  FUNDING_AGENCY5           ,
                  FUNDING_AGENCY6           ,
                  GRANT_NUMBER              ,
                  GRANT_NUMBER2             ,
                  GRANT_NUMBER3             ,
                  GRANT_NUMBER4             ,
                  GRANT_NUMBER5             ,
                  GRANT_NUMBER6             ,
                  PI_EMAIL                  ,
                  PI_FIRST_NAME             ,
                  PI_LAST_NAME              ,
                  PREVIOUS_PROTOCOL_NUMBER  ,
                  PROPOSAL_TYPE             ,
                  PROTOCOL_NUMBER           ,
                  REVIEW_LEVEL              ,
                  SUBMISSION_DATE           ,
                  WBS_IP_1                  ,
                  WBS_IP_2                  ,
                  WBS_IP_3                  ,
                  WBS_IP_4                  ,
                  WBS_IP_5                  ,
                  WBS_IP_6 )
  select    SEQ_CAC_DATA_ID.NEXTVAL,
            APPROVAL_DATE             ,
              CONTACT_EMAIL             ,
              DEPT                      ,
              EXPIRATION_DATE           ,
              FUNDING_AGENCY            ,
              FUNDING_AGENCY2           ,
              FUNDING_AGENCY3           ,
              FUNDING_AGENCY4           ,
              FUNDING_AGENCY5           ,
              FUNDING_AGENCY6           ,
              GRANT_NUMBER              ,
              GRANT_NUMBER2             ,
              GRANT_NUMBER3             ,
              GRANT_NUMBER4             ,
              GRANT_NUMBER5             ,
              GRANT_NUMBER6             ,
              PI_EMAIL                  ,
              PI_FIRST_NAME             ,
              PI_LAST_NAME              ,
              PREVIOUS_PROTOCOL_NUMBER  ,
              PROPOSAL_TYPE             ,
              PROTOCOL_NUMBER           ,
              REVIEW_LEVEL              ,
              SUBMISSION_DATE           ,
              WBS_IP_1                  ,
              WBS_IP_2                  ,
              WBS_IP_3                  ,
              WBS_IP_4                  ,
              WBS_IP_5                  ,
              WBS_IP_6      
       from CAC_DATA@coeus.kuali
/
insert into cac_log_data(
                  CAC_LOG_DATA_ID,
                  PROTOCOL_NUMBER_CAC             ,
                  AWARD_IP_NUMBER             ,
                  WBS_IP_CAC                      ,
                  COMMENTS           ,
                  LOG_NOTE            ,
                  SPREV_APPROVAL_DATE           ,
                  AWARD_EXPIRATION_DATE           ,
                  SUBMISSION_DATE_CAC           ,
                  APPROVAL_DATE_CAC           ,
                  LOG_INDICATOR           ,
                  UPDATE_TIMESTAMP              ,
                  VER_NBR             ,
                  OBJ_ID  )
  select    SEQ_CAC_LOG_DATA_ID.NEXTVAL,
            PROTOCOL_NUMBER_CAC             ,
                  AWARD_IP_NUMBER             ,
                  WBS_IP_CAC                      ,
                  COMMENTS           ,
                  LOG_NOTE            ,
                  SPREV_APPROVAL_DATE           ,
                  AWARD_EXPIRATION_DATE           ,
                  SUBMISSION_DATE_CAC           ,
                  APPROVAL_DATE_CAC           ,
                  LOG_INDICATOR           ,
                  UPDATE_TIMESTAMP              ,
                  1,
                  SYS_GUID()    
       from CAC_LOG_DATA@coeus.kuali
/
/*
declare
    
  ll_cac_data_rows Number := 0; 
 
  
 begin
  select count(protocol_number)
  into ll_cac_data_rows
  from cac_data@coeus.kuali;
  
  if ll_cac_data_rows >0 then  
    
    declare cursor c_cac_data is 
    select    APPROVAL_DATE             ,
              CONTACT_EMAIL             ,
              DEPT                      ,
              EXPIRATION_DATE           ,
              FUNDING_AGENCY            ,
              FUNDING_AGENCY2           ,
              FUNDING_AGENCY3           ,
              FUNDING_AGENCY4           ,
              FUNDING_AGENCY5           ,
              FUNDING_AGENCY6           ,
              GRANT_NUMBER              ,
              GRANT_NUMBER2             ,
              GRANT_NUMBER3             ,
              GRANT_NUMBER4             ,
              GRANT_NUMBER5             ,
              GRANT_NUMBER6             ,
              PI_EMAIL                  ,
              PI_FIRST_NAME             ,
              PI_LAST_NAME              ,
              PREVIOUS_PROTOCOL_NUMBER  ,
              PROPOSAL_TYPE             ,
              PROTOCOL_NUMBER           ,
              REVIEW_LEVEL              ,
              SUBMISSION_DATE           ,
              WBS_IP_1                  ,
              WBS_IP_2                  ,
              WBS_IP_3                  ,
              WBS_IP_4                  ,
              WBS_IP_5                  ,
              WBS_IP_6                  
     from CAC_DATA@coeus.kuali;
     r_cac_data c_cac_data%rowtype;
    
    begin 
         open c_cac_data;
         loop
         fetch c_cac_data into r_cac_data;
         exit when c_cac_data%notfound;
         
         --begin
            insert into cac_data(
                  CAC_DATA_ID,
                  APPROVAL_DATE             ,
                  CONTACT_EMAIL             ,
                  DEPT                      ,
                  EXPIRATION_DATE           ,
                  FUNDING_AGENCY            ,
                  FUNDING_AGENCY2           ,
                  FUNDING_AGENCY3           ,
                  FUNDING_AGENCY4           ,
                  FUNDING_AGENCY5           ,
                  FUNDING_AGENCY6           ,
                  GRANT_NUMBER              ,
                  GRANT_NUMBER2             ,
                  GRANT_NUMBER3             ,
                  GRANT_NUMBER4             ,
                  GRANT_NUMBER5             ,
                  GRANT_NUMBER6             ,
                  PI_EMAIL                  ,
                  PI_FIRST_NAME             ,
                  PI_LAST_NAME              ,
                  PREVIOUS_PROTOCOL_NUMBER  ,
                  PROPOSAL_TYPE             ,
                  PROTOCOL_NUMBER           ,
                  REVIEW_LEVEL              ,
                  SUBMISSION_DATE           ,
                  WBS_IP_1                  ,
                  WBS_IP_2                  ,
                  WBS_IP_3                  ,
                  WBS_IP_4                  ,
                  WBS_IP_5                  ,
                  WBS_IP_6 )
           VALUES(
                  SEQ_CAC_DATA_ID.NEXTVAL,
                  r_cac_data.APPROVAL_DATE             ,
                  r_cac_data.CONTACT_EMAIL             ,
                  r_cac_data.DEPT                      ,
                  r_cac_data.EXPIRATION_DATE           ,
                  r_cac_data.FUNDING_AGENCY            ,
                  r_cac_data.FUNDING_AGENCY2           ,
                  r_cac_data.FUNDING_AGENCY3           ,
                  r_cac_data.FUNDING_AGENCY4           ,
                  r_cac_data.FUNDING_AGENCY5           ,
                  r_cac_data.FUNDING_AGENCY6           ,
                  r_cac_data.GRANT_NUMBER              ,
                  r_cac_data.GRANT_NUMBER2             ,
                  r_cac_data.GRANT_NUMBER3             ,
                  r_cac_data.GRANT_NUMBER4             ,
                  r_cac_data.GRANT_NUMBER5             ,
                  r_cac_data.GRANT_NUMBER6             ,
                  r_cac_data.PI_EMAIL                  ,
                  r_cac_data.PI_FIRST_NAME             ,
                  r_cac_data.PI_LAST_NAME              ,
                  r_cac_data.PREVIOUS_PROTOCOL_NUMBER  ,
                  r_cac_data.PROPOSAL_TYPE             ,
                  r_cac_data.PROTOCOL_NUMBER           ,
                  r_cac_data.REVIEW_LEVEL              ,
                  r_cac_data.SUBMISSION_DATE           ,
                  r_cac_data.WBS_IP_1                  ,
                  r_cac_data.WBS_IP_2                  ,
                  r_cac_data.WBS_IP_3                  ,
                  r_cac_data.WBS_IP_4                  ,
                  r_cac_data.WBS_IP_5                  ,
                  r_cac_data.WBS_IP_6       );
         --end;
         end loop;
       CLOSE c_cac_data;  
       commit;
    end;
  end if;  
end;
/
*/