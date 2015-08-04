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
6,
'557',
'KC Person Feed Prncpl ID cleanup',
'KC Person Feed Prncpl ID cleanup',
'<p>Following Kerberos IDs were set as Inactive from person feed.<p>
<br/><br/>Person_id:</b>     {PERSON_ID} 
<br/><b>User_name: </b>    {USER_NAME} 
<br/><b>Full_name: </b>  {FULL_NAME}',
'N',
'Y',
USER,
sysdate,
1,
sys_guid()
)
/