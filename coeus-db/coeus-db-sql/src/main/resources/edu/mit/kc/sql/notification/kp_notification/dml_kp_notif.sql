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
'602',
'Key Person Confirmation',
'Key Person Confirmation',
'You have been named as a Senior/Key Person on an award subject to the PHS/NIH Conflict of Interest requirements. <br/>
<p>PI: {PI_NAME} <br/>Lead Unit: {LEAD_UNIT} : {LEAD_UNIT_NAME} <br/>MIT Award Number: {AWARD_NUMBER}<br/>MIT Account Number: {ACCOUNT_NUMBER}<br/>
<p>As a Senior/Key Person on this award, you are subject to Conflict of Interest requirements (http://coi.mit.edu/research/policy). You must comply with all of the requirements before your salary can be charged to the award.
<p>MIT policy requires that you complete a conflict of interest disclosure.
<p>Please complete your Conflict of Interest Disclosure. Instructions can be found at http://coi.mit.edu/research/how-to-disclose-in-coeus.
<p>Should you have any questions, please contact your OSP Contract Administrator (http://osp.mit.edu/about-osp/staff/by-department). ',
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
1,
'603',
'Key Person Confirmation',
'Key Person Confirmation',
'You have been named as a Senior/Key Person on an award subject to the PHS/NIH Conflict of Interest requirements. <br/>
<p>PI: {PI_NAME} <br/>Lead Unit: {LEAD_UNIT} : {LEAD_UNIT_NAME} <br/>MIT Award Number: {AWARD_NUMBER}<br/>MIT Account Number: {ACCOUNT_NUMBER}<br/>
<p>As a Senior/Key Person, you are subject to the new PHS/NIH Conflict of Interest requirements (http://coi.mit.edu/research/sponsor-specific-guidelines/nih).  The new regulations go into effect on August 24, 2012, and apply to new and continuation awards issued on or after that date.  You must comply with all of the requirements before your salary can be charged to the award. 
<p>The regulations require:
<p>1.  Training on the PHS Conflict of Interest regulations and MIT Policy (renewed every four years)
<br/>2.  Completion of an annual conflict of interest disclosure and updates within 30 days of acquiring a new significant financial interest. 
<br/>3.  Disclosure of travel reimbursed or paid on your behalf with certain exceptions 
<br/> http://coi.mit.edu/research/how-to-disclose-in-coeus/travel-disclosure ',
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/