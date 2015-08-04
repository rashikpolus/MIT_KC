INSERT INTO COEUS_MODULE(
MODULE_CODE,
DESCRIPTION,
UPDATE_TIMESTAMP,
UPDATE_USER,
VER_NBR,
OBJ_ID
)
VALUES(
101,
'NDA',
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
101,
'501',
'NDA Survey Completion report',
'NDA Survey Completion report : {NDA_NUMBER}',
'<p>Dear NDA Team,  </p>'||CHR( 13 ) || CHR( 10 )||
'<table border="1">
<tr>
<td><b>NDA#</b></td>
<td> {NDA_NUMBER} </td>
</tr>
<tr>
<td><b>PI</b></td>
<td> {PI_NAME} </td>
</tr>
<tr>
<td><b>Organization</b></td>
<td>  {ORG_NAME} </td>
</tr>
<tr>
<td><b>Identifier</b></td>
<td> {TITLE} </td>
</tr>
</table> '|| CHR( 13 ) || CHR( 10 )||
'<p><a href="http://coeus-dev1.mit.edu/NoviSurvey/ShowResponse.aspx?doid={SURVEY_RESPONSE_ID}&s=edb1385874ee465cb7d81665d9718682"'||
'<b>Click here</a> to view the answers to this NDA Questionnaire</b></p>'||CHR( 13 ) || CHR( 10 )||CHR( 13 ) || CHR( 10 ),
'N',
'Y',
user,
sysdate,
1,
sys_guid()
)
/
TRUNCATE TABLE NDA
/
INSERT INTO NDA (
	NDA_NUMBER,
	PERSON_ID,
	TITLE,
	CREATE_DATE,
	ORGANIZATION_NAME,
	SURVEY_ID,
	COMPLETION_DATE,
	VER_NBR,
	OBJ_ID)
SELECT
	NDA_NUMBER,
	PERSON_ID,
	TITLE,
	CREATE_DATE,
	ORGANIZATION_NAME,
	SURVEY_ID,
	COMPLETION_DATE,
	1,
	SYS_GUID()
FROM OSP$NDA@coeus.kuali
/
commit
/
declare
li_max number(10);
ls_query VARCHAR2(400);
begin
select max(NDA_NUMBER) into li_max from NDA;
ls_query:='alter sequence SEQ_NDA_NUMBER increment by '||li_max;      
execute immediate(ls_query);  

end;
/
select SEQ_NDA_NUMBER.NEXTVAL from dual
/
alter sequence SEQ_NDA_NUMBER increment by 1
/