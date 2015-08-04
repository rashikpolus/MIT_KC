set define off
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
100,
'501',
'RCR - Day after appointment',
'Responsible Conduct of Research training required by {TRAINING_DEADLINE}',
'Dear {TRAINEE_NAME}:'||CHR(10)||'
<p>You are receiving this message because your salary is currently supported by a grant 
from the National Science Foundation (NSF).  NSF requires that all undergraduate students, 
graduate students and postdoctoral associates and fellows supported on its awards complete 
Responsible Conduct of Research training.  MIT is using the online CITI Program to meet 
this requirement. </p>'||CHR(10)||'  
<p>You must complete this training by {TRAINING_DEADLINE}.'||CHR(10)||'
You can access the program at http://osp.mit.edu/compliance/rcr.  
Use this link to ensure that your training is recorded appropriately.  You will need an 
MIT certificate for this to work properly - see https://ca.mit.edu for instructions on how 
to install a certificate on your computer.  If you are new to MIT, consult Getting Your 
Electronic Credentials http://ist.mit.edu/start/newhires.  
The training takes ~6-8 hours to complete, can be done in multiple sittings and contains important information on the 
following topics:</p>'||CHR(10)||'
<ul>
<li>Introduction to the Responsible Conduct of Research</li>
<li>Research Misconduct</li>
<li>Data Acquisition and Management</li>
<li>Responsible Authorship</li>
<li>Peer Review</li>
<li>Mentoring</li>
<li>Conflicts of Interest</li>
<li>Collaborative Research</li>
</ul>
<p>Your Principal Investigator/Mentor is aware of this requirement and can 
help you determine which module is most relevant to your work. The options are Biomedical 
Sciences, Social and Behavioral Sciences, Humanities, Physical Sciences, and Engineering.  </p>
<p>If you have already completed the CITI RCR training at another institution, 
instructions for how to have your records transferred to MIT can be found at - http://osp.mit.edu/compliance/responsible-conduct-of-research-rcr/register-for-rcr-training     
If you have any questions regarding MIT''s policy regarding NSF RCR Training, please visit the OSP 
website - http://osp.mit.edu/compliance/responsible-conduct-of-research-rcr/rcr-implementation-plan or 
contact your PI and/or local departmental administrator.</p>
<p>Thank you, <br /> 
Office of Sponsored Programs and Office of the Vice President for Research & Associate Provost</p>',
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
100,
'502',
'RCR - 25 days after payroll post',
'FINAL REMINDER: Responsible Conduct of Research training - due now ',
'Dear {TRAINEE_NAME}:'||CHR(10)||'
<p>REMINDER: You are receiving this message because you are currently funded by a grant from the National Science Foundation and our records indicate that you have not yet completed the Responsible Conduct of Research (RCR) training requirement. </p> 
<p>You must complete this training by <b> {TRAINING_DEADLINE}  </b> in order to continue working on this project.   If you do not, your Principal Investigator/Mentor will be notified.</p>'||CHR(10)||'<p>To access the training:</p>
<ul>
<li>Verify that you have an MIT Kerberos certificate on your computer.  See https://ca.mit.edu for instructions on how to install a certificate on your computer. (Those new to MIT should consult Getting Your Electronic Credentials http://ist.mit.edu/start/newhires.)  </li>
<li>Access the CITI training page through http://osp.mit.edu/compliance/responsible-conduct-of-research-rcr/register-for-rcr-training to ensure that your records are transmitted directly to MIT.</li>
</ul>'||CHR(10)||'
<p>If you have any questions regarding MIT''s policy regarding NSF RCR Training, please visit the 
OSP website - http://osp.mit.edu/compliance/responsible-conduct-of-research-rcr/rcr-implementation-plan or contact your PI or local department administrator.</p>'||CHR(10)||'
<p>Thank you, <br/> 
Office of Sponsored Programs and Office of the Vice President for Research & Associate Provost</p>'	,
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
--Notification3-------------------
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
100,
'503',
'RCR - 30 days after payroll post',
'RCR training still required',
'<p>The following individuals working on your NSF grant(s) did not complete the required RCR training within 
the recommended time period (30 days from the first salary posting).</p> '||CHR(10)||'
{STUDENT_LIST}	
'||CHR(10)||'		
<p>Please ensure that this training is completed by the date listed above.  
If it is not completed by that time, their salary charges will be removed from the grant and charged to the PI''s discretionary account, 
since the costs will no longer be allowable on a sponsored award.</p> '||CHR(10)||'			
<p>You will receive an updated list of individuals who still require training 15 days prior to the final deadline.  
OSP regularly updates and posts training reports to the RCR website http://osp.mit.edu/compliance/responsible-conduct-of-research-rcr/rcr-training-reports.  
If you believe an individual has completed the training but is not listed on this report, please contact rcr-help@mit.edu.</p> '||CHR(10)||'
<p>Thank you, <br /> 
Office of Sponsored Programs and Office of the Vice President for Research & Associate Provost</p>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
--Notification4
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
100,
'504',
'RCR - 45 days after payroll post',
'RCR training still required',
'<p>The following individuals working on the NSF grant(s) below have not 
completed the required RCR training and have only 15 days left to comply with this requirement.  </p> 
'||CHR(10)||'
{STUDENT_LIST}			
'||CHR(10)||'
<p>Please ensure that this training is completed by the date listed above.  
If it is not completed by that time, their salary charges will be removed from the 
grant and charged to the PI''s discretionary account, since the costs will no longer be 
allowable on a sponsored award.  </p>'||CHR(10)||'
<p>OSP regularly updates and posts training reports to the RCR website 
http://osp.mit.edu/compliance/responsible-conduct-of-research-rcr/rcr-training-reports.  
If you believe an individual has completed the training but is not listed on this report, 
please contact rcr-help@mit.edu. </p> '||CHR(10)||'
<p>Thank you, <br /> 
Office of Sponsored Programs and Office of the Vice President for Research & Associate Provost</p>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
--Notification5
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
100,
'505',
'RCR - 45 days after payroll post - Assitant Dean',
'RCR training still required',
'<p>Dear {ADMINISTRATOR_NAME}:
<p>The following awards have individuals who have not completed the required RCR training.   
This training must be completed by the date listed below or the salary costs will not be allowable.  </p> 
'||CHR(10)||'
{STUDENT_LIST}		
'||CHR(10)||'	
<p>Thank you, <br /> '||CHR(10)||'
Office of Sponsored Programs and Office of the Vice President for Research & Associate Provost</p>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
--Notification6 -- training completion
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
100,
'506',
'RCR - Training complete notification',
'RCR - Training complete notification',
'<p>Dear {TRAINEE_NAME}:'||CHR(10)||'
<p>We have received confirmation form CITI that you have completed the RCR training program.  
Thank you for your cooperation.</p>	
'||CHR(10)||'	
<p>Thank you, <br /> 
Office of Sponsored Programs and Office of the Vice President for Research & Associate Provost</p>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
INSERT INTO RCR_APPOINTMENTS(
	RCR_APPOINT_ID,
	PERSON_ID,
	ACCOUNT_NUMBER,
	APPOINTMENT_DATE,
	APPOINTMENT_TYPE,
	DATA_LOAD_DATE,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID
)  
SELECT
	SEQ_RCR_APPOINT_ID.nextval,
	PERSON_ID,
	ACCOUNT_NUMBER,
	APPOINTMENT_DATE,
	APPOINTMENT_TYPE,
	DATA_LOAD_DATE,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
FROM OSP$RCR_APPOINTMENTS@coeus.kuali
/
INSERT INTO RCR_PAYROLL_DATES(
	RCR_PAYROLL_DATES_ID,
	PERSON_ID,
	ACCOUNT_NUMBER,
	PAYROLL_NUMBER,
	BASE_DATE,
	TRAINING_DEADLINE,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID
)
SELECT
	SEQ_RCR_PAYROLL_DATES_ID.nextval,
	PERSON_ID,
	ACCOUNT_NUMBER,
	PAYROLL_NUMBER,
	BASE_DATE,
	TRAINING_DEADLINE,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
FROM OSP$RCR_PAYROLL_DATES@coeus.kuali
/
INSERT INTO RCR_NOTIFICATIONS(
	NOTIFICATION_ID,
	NOTIFICATION_TYPE_CODE,
	NOTIFICATION_DATE,
	NO_OF_DAYS_PRIOR,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID
)
SELECT 
	NOTIFICATION_ID,
	decode(NOTIFICATION_TYPE_CODE,5,105,4,104,3,103,2,102,1,101),
	NOTIFICATION_DATE,
	NO_OF_DAYS_PRIOR,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
FROM OSP$RCR_NOTIFICATIONS@coeus.kuali
/
commit
/
INSERT INTO RCR_NOTIF_DETAILS(
	NOTIFICATION_ID,
	PERSON_ID,
	ACCOUNT_NUMBER,
	RECIPIENT_ROLE,
	RECIPIENT_ID,
	TRAINING_DEADLINE,
	MAIL_SENT_STATUS,
	RECIPIENT_EMAIL,
	UNIT_NUMBER,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID
)
SELECT
	NOTIFICATION_ID,
	PERSON_ID,
	ACCOUNT_NUMBER,
	RECIPIENT_ROLE,
	RECIPIENT_ID,
	TRAINING_DEADLINE,
	'Y',
	RECIPIENT_EMAIL,
	UNIT_NUMBER,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
FROM OSP$RCR_NOTIF_DETAILS@coeus.kuali
/
INSERT INTO RCR_NOTIF_TYPE(
  RCR_NOTIF_TYPE_CODE,
  NOTIFICATION_TYPE_ID,
  DESCRIPTION,
  NO_OF_DAYS_PRIOR,
  UPDATE_TIMESTAMP,
  UPDATE_USER
)
 Values
   (1, (SELECT 	NOTIFICATION_TYPE_ID FROM NOTIFICATION_TYPE WHERE MODULE_CODE = 100 AND  ACTION_CODE = 501) ,'RCR - Day after appointment', 0, sysdate, user)
/
INSERT INTO RCR_NOTIF_TYPE(
  RCR_NOTIF_TYPE_CODE,
  NOTIFICATION_TYPE_ID,
  DESCRIPTION,
  NO_OF_DAYS_PRIOR,
  UPDATE_TIMESTAMP,
  UPDATE_USER
)
 Values    
   (2, (SELECT 	NOTIFICATION_TYPE_ID FROM NOTIFICATION_TYPE WHERE MODULE_CODE = 100 AND  ACTION_CODE = 502) ,'RCR - 25 days after payroll post', 25,sysdate, user )
/
INSERT INTO RCR_NOTIF_TYPE(
  RCR_NOTIF_TYPE_CODE,
  NOTIFICATION_TYPE_ID,
  DESCRIPTION,
  NO_OF_DAYS_PRIOR,
  UPDATE_TIMESTAMP,
  UPDATE_USER
)
 Values    
   (3, (SELECT 	NOTIFICATION_TYPE_ID FROM NOTIFICATION_TYPE WHERE MODULE_CODE = 100 AND  ACTION_CODE = 503) ,'RCR - 30 days after payroll post', 30, sysdate, user)
/
INSERT INTO RCR_NOTIF_TYPE(
  RCR_NOTIF_TYPE_CODE,
  NOTIFICATION_TYPE_ID,
  DESCRIPTION,
  NO_OF_DAYS_PRIOR,
  UPDATE_TIMESTAMP,
  UPDATE_USER
)
 Values    
   (4,(SELECT 	NOTIFICATION_TYPE_ID FROM NOTIFICATION_TYPE WHERE MODULE_CODE = 100 AND  ACTION_CODE = 504) , 'RCR - 45 days after payroll post', 45, sysdate, user)
/
INSERT INTO RCR_NOTIF_TYPE(
  RCR_NOTIF_TYPE_CODE,
  NOTIFICATION_TYPE_ID,
  DESCRIPTION,
  NO_OF_DAYS_PRIOR,
  UPDATE_TIMESTAMP,
  UPDATE_USER
)
 Values    
   (5, (SELECT 	NOTIFICATION_TYPE_ID FROM NOTIFICATION_TYPE WHERE MODULE_CODE = 100 AND  ACTION_CODE = 505) ,'RCR - 45 days after payroll post - Assitant Dean', 45,sysdate, user)
/
declare
li_max number(10);
ls_query VARCHAR2(400);
begin
select max(NOTIFICATION_ID) into li_max from RCR_NOTIFICATIONS;
ls_query:='alter sequence SEQ_RCR_NOTIFICATION_ID increment by '||li_max;      
execute immediate(ls_query);  

end;
/
select SEQ_RCR_NOTIFICATION_ID.NEXTVAL from dual
/
alter sequence SEQ_RCR_NOTIFICATION_ID increment by 1
/
declare
ls_msg VARCHAR2(4000);
li_ntfctn_id KREN_NTFCTN_T.NTFCTN_ID%TYPE;

cursor c_data is
select NOTIFICATION_ID,NOTIFICATION_TYPE_CODE from OSP$RCR_NOTIFICATIONS@coeus.kuali;
r_data c_data%rowtype;

li_notification_typ NUMBER;
ll_cntnt CLOB;

begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

if r_data.NOTIFICATION_TYPE_CODE = 1 then
	li_notification_typ := 101;
elsif r_data.NOTIFICATION_TYPE_CODE = 2 then
	li_notification_typ := 102;
elsif r_data.NOTIFICATION_TYPE_CODE = 3 then
	li_notification_typ := 103;
elsif r_data.NOTIFICATION_TYPE_CODE = 4 then
	li_notification_typ := 104;
elsif r_data.NOTIFICATION_TYPE_CODE = 5 then
	li_notification_typ := 105;
end if;

	begin
		select message into ls_msg from NOTIFICATION_TYPE 
		where MODULE_CODE = 100
		and ACTION_CODE = li_notification_typ;
	exception
	when others then
	ls_msg := ' ';
	end;
	
ll_cntnt := q'<<content xmlns="ns:notification/ContentTypeSimple" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="ns:notification/ContentTypeSimple resource:notification/ContentTypeSimple"><message><![CDATA[ >'||ls_msg||q'<  .]]></message></content>>';

	li_ntfctn_id := KREN_NTFCTN_S.NEXTVAL;
begin
	INSERT INTO KREN_NTFCTN_T(
		NTFCTN_ID,
		DELIV_TYP,
		CRTE_DTTM,
		SND_DTTM,	
		PRIO_ID,
		TTL,
		CNTNT,
		CNTNT_TYP_ID,
		CHNL_ID,
		PRODCR_ID,
		PROCESSING_FLAG	,
		VER_NBR,
		OBJ_ID,
		DOC_TYP_NM
	)
	VALUES(
		li_ntfctn_id,
		'FYI',
		sysdate,
		sysdate,
		1,
		'RCR-Notification from migration',
		ll_cntnt,
		1,
		1000,
		1000,
		'RESOLVED',
		1,
		SYS_GUID(),
		'KcNotificationDocument'
	);

	INSERT INTO KREN_NTFCTN_MSG_DELIV_T(
		NTFCTN_MSG_DELIV_ID,
		NTFCTN_ID,
		RECIP_ID,
		STAT_CD,
		SYS_ID,
		LOCKD_DTTM,
		VER_NBR,
		OBJ_ID
	)	
 select 
 	KREN_NTFCTN_MSG_DELIV_S.NEXTVAL,
		li_ntfctn_id,
		t1.PERSON_ID,
		'DELIVERED',
		NULL,
		NULL,
		1,
		SYS_GUID()	
 from
 ( select  
	DISTINCT	PERSON_ID	
	from OSP$RCR_NOTIF_DETAILS@coeus.kuali
	where NOTIFICATION_ID = r_data.NOTIFICATION_ID
 ) t1;
exception
when others then
null;
 end;
	commit;
	
end loop;
close c_data;

end;
/
truncate table TRAINING_MODULES
/
INSERT INTO TRAINING_MODULES(
TRAINING_MODULES_ID,
TRAINING_CODE,
MODULE_CODE,
SUB_MODULE_CODE,
DESCRIPTION,
UPDATE_TIMESTAMP,
UPDATE_USER,
VER_NBR,
OBJ_ID
)
SELECT 
SEQ_TRAINING_MODULES_ID.NEXTVAL,
TRAINING_CODE,
MODULE_CODE,
SUB_MODULE_CODE,
DESCRIPTION,
UPDATE_TIMESTAMP,
UPDATE_USER,
1,
sys_guid()
FROM OSP$TRAINING_MODULES@coeus.kuali
/
