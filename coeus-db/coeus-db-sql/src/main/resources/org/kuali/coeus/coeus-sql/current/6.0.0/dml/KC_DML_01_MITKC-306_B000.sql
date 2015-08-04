INSERT INTO NOTIFICATION_TYPE (NOTIFICATION_TYPE_ID, MODULE_CODE, ACTION_CODE, DESCRIPTION, SUBJECT, MESSAGE, PROMPT_USER, SEND_NOTIFICATION, UPDATE_USER, UPDATE_TIMESTAMP, VER_NBR, OBJ_ID)
VALUES (SEQ_NOTIFICATION_TYPE_ID.NEXTVAL, (SELECT MODULE_CODE FROM COEUS_MODULE WHERE DESCRIPTION='Development Proposal'), '108','Notification when a proposal approval reaches OSP office',
'OSP is working on {PRINCIPAL INVESTIGATOR}''s proposal to {SPONSOR_NAME} - MIT Proposal {PROPOSAL_NUMBER}',
'The Office of Sponsored Program''s just received your proposal, and {CA_FIRST_NAME} {CA_LAST_NAME} will be handling it for you.<br/><br/>
You will hear from us shortly about the status of the proposal. In the meantime, please contact {CA_FIRST_NAME} with any questions at {CA_EMAIL} or
{CA_PHONE}.<br/><br/>Proposal Details:<br/><br/>PI: {PRINCIPAL INVESTIGATOR}<br/>Profit Center: {LEAD_UNIT}{LEAD_UNIT_NAME}<br/>Proposal Number: {PROPOSAL_NUMBER}<br/> 
Sponsor: {SPONSOR_NAME}<br/>Deadline Date: {DEADLINE_DATE}<br/>Title: {PROPOSAL_TITLE}<br/>Sponsor Announcement: {PROGRAM_ANNOUNCEMENT_NUMBER}<br/><br/><br/>
{WL_FUN_FACTS}<br/><br/>MIT Office of Sponsored Programs<br/>77 Massachusetts Avenue, Bldg. NE18-901 Cambridge MA 02139',
'N', 'Y', 'admin', SYSDATE, 1, SYS_GUID())
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) 
VALUES ('KC-GEN', 'All', 'WL_FUN_FACTS', SYS_GUID(), '1', 'CONFG',
'Did you know...that on average, MIT''s success rate is more than 40% for federal proposals (well above the agency averages), and about 60% for all
other sponsors? We wish you the best of luck!', 'fun facts for work load balancing notification', 'A', 'KC')
/
