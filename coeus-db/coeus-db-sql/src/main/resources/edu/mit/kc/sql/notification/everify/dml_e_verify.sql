set define off
/
INSERT INTO EVERIFY_NOTIFICATIONS (
   NOTIFICATION_ID, NOTIFICATION_DATE, UPDATE_TIMESTAMP, 
   UPDATE_USER, VER_NBR	,  OBJ_ID) 
VALUES ( SEQ_everify_NOTIFICATION_ID.nextval, sysdate -1, sysdate -1 , user,1,sys_guid());
set define off;
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
1,
'601',
'eVerify - Award Accounts Subject to E-Verify Certification',
'Award Accounts Subject to E-Verify Certification',
'This award is subject to FAR Clause 52.222-54 Employment Eligibility Verification.
All employees and student employees charged to this award must have their employment eligibility verified on-line through the E-Verify process.
I-9 Central/Student Financial Services will be notified prior to the distribution of the cost to the contract and will complete the E-Verification process. If there is missing, unavailable or expired information they will contact the DLC I-9 Administrator and the employee for the information.
The process must be completed within 30 business days from the date the employee/student was assigned to the contract. If you are unsure if your award has this requirement, please review the COEUS Award module under Others Approvals tab.
If there is another individual in your department who is responsible for the completion of employment (such as hire) transactions, please forward this information to them so they will be aware of the E-Verify requirement for employees and student employees assigned to this award.
<br/><br/>
If you have questions about the E-Verification of employees contact I-9central@mit.edu,for students contact Gary Ryan in Student Financial Services at gryan@mit.edu.
<br/><br/>
<table border="1">
<tr>
<th>AWARD NUMBER&nbsp; &nbsp; &nbsp; </th>
<th>ACCOUNT NUMBER&nbsp; &nbsp; &nbsp;  </th>
</tr>
{AWARD_LIST}
</table>',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
INSERT INTO EVERIFY_NOTIFICATIONS(
	NOTIFICATION_ID,
	NOTIFICATION_DATE,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID)
SELECT 
	NOTIFICATION_ID,
	NOTIFICATION_DATE,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
FROM OSP$EVERIFY_NOTIFICATIONS@coeus.kuali
/
INSERT INTO EVERIFY_NOTIF_DETAILS(
	NOTIF_DETAILS_ID,
	NOTIFICATION_ID,
	AWARD_NUMBER,
	SEQUENCE_NUMBER,
	RECIPIENT_ID,
	RECIPIENT_ROLE,
	RECIPIENT_EMAIL,
	UNIT_NUMBER,
	MAIL_SENT_STATUS,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID)
SELECT
	SEQ_EVERIFY_NOTIF_DETAILS_ID.NEXTVAL,
	NOTIFICATION_ID,
	MIT_AWARD_NUMBER,
	SEQUENCE_NUMBER,
	RECIPIENT_ID,
	RECIPIENT_ROLE,
	RECIPIENT_EMAIL,
	UNIT_NUMBER,
	'Y',
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
FROM OSP$EVERIFY_NOTIF_DETAILS@coeus.kuali
/
commit
/
declare
li_max number(10);
ls_query VARCHAR2(400);
begin
select max(NOTIFICATION_ID) into li_max from EVERIFY_NOTIFICATIONS;
ls_query:='alter sequence SEQ_EVERIFY_NOTIFICATION_ID increment by '||li_max;      
if li_max is not null then
	execute immediate(ls_query);  
end if;

end;
/
select SEQ_EVERIFY_NOTIFICATION_ID.NEXTVAL from dual
/
alter sequence SEQ_EVERIFY_NOTIFICATION_ID increment by 1
/
UPDATE NOTIFICATION_TYPE
SET MESSAGE ='This award is subject to FAR Clause 52.222-54 Employment Eligibility Verification.
All employees and student employees charged to this award must have their employment eligibility verified on-line through the E-Verify process.
I-9 Central/Student Financial Services will be notified prior to the distribution of the cost to the contract and will complete the E-Verification process. If there is missing, unavailable or expired information they will contact the DLC I-9 Administrator and the employee for the information.
The process must be completed within 30 business days from the date the employee/student was assigned to the contract. If you are unsure if your award has this requirement, please review the COEUS Award module under Others Approvals tab.
If there is another individual in your department who is responsible for the completion of employment (such as hire) transactions, please forward this information to them so they will be aware of the E-Verify requirement for employees and student employees assigned to this award.
<br/><br/>
If you have questions about the E-Verification of employees contact I-9central@mit.edu,for students contact Gary Ryan in Student Financial Services at gryan@mit.edu.
<br/><br/>
<table border="1">
<tr>
<th>AWARD NUMBER&nbsp; &nbsp; &nbsp; </th>
<th>ACCOUNT NUMBER&nbsp; &nbsp; &nbsp;  </th>
</tr>
{AWARD_LIST}
</table>'
WHERE MODULE_CODE=1
AND ACTION_CODE=601
/