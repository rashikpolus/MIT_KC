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
5,
'500',
'longitudinal survey for following negotiation',
'longitudinal survey for following negotiation',
'<table border="1">
<tr>
<td><b>Negotiation#</b></td>
<td> {NEGOTIATION_NUMBER} </td>
</tr>
<tr>
<td><b>PI</b></td>
<td> {PI_NAME} </td>
</tr>
<tr>
<td><b>Lead Unit</b></td>
<td> {UNIT_NUMBER}  : {UNIT_NAME} </td>
</tr>
<tr>
<td><b>Sponsor</b></td>
<td> {SPONSOR_CODE} : {SPONSOR_NAME} </td>
</tr>
<tr>
<td><b>Title</b></td>
<td> {TITLE} </td>
</tr>
<tr>
<td><b>Negotiator</b></td>
<td> {FULL_NAME} </td>
</tr>
<tr>
<td><b>Start Date</b></td>
<td> {START_DATE} </td>
</tr>              
</table> 
<p><h3>Survey Response</h3></p>
<table border="1">
<tr>
<th>Question</th>
<th>Response</th>
</tr>
<tr>
<td>  {QUESTION_DESC}  </td>
<td><b> {ANSWER} </b></td>
</tr>
</table>',
'N',
'Y',
USER,
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
5,
'501',
'As part of MIT''s Office of Sponsored Program''s (OSP) ongoing effort to improve our services to the MIT research community',
'As part of MIT''s Office of Sponsored Program''s (OSP) ongoing effort to improve our services to the MIT research community',
'<p>Dear Dr. {LAST_NAME} </p>'||CHR( 13 ) || CHR( 10 )||'As part of MIT''s Office of Sponsored Program''s (OSP) ongoing effort to improve our services to the MIT research community, we would like to learn about your level of satisfaction with our negotiation of the  <b> {AGREEMENT_TYPE} </b>with <b> {SPONSOR_NAME} </b> that OSP just completed negotiating on your behalf.  Your feedback about how we conducted this negotiation of a research-related agreement with a non-federal sponsor will support OSP''s continuous improvement of the negotiation of agreements with similar sponsors in the future.'||CHR( 13 ) || CHR( 10 )||'<p><b>Your answers to this survey will be kept confidential within OSP, discussed by OSP senior management with your negotiator as feedback to help improve our future negotiation services. Your answers will not be shared in any public forum.</b> The results of all completed surveys will be aggregated into a quarterly composite measure of PIs'' satisfaction with OSP''s negotiation services.'||CHR( 13 ) || CHR( 10 )||'<p>This short multiple-choice survey should take just two minutes to complete.   If you do not wish to provide feedback to us regarding <u>this</u> agreement''s negotiation, you may ignore this invitation and we will not send a reminder.'||CHR( 13 ) || CHR( 10 )||'<p>We hope that you will provide your feedback to OSP, and thank you for your time!',
'N',
'Y',
USER,
sysdate,
1,
sys_guid()
)
/
insert into KRIM_PERM_T (
PERM_ID,
OBJ_ID,
VER_NBR,
PERM_TMPL_ID,
NMSPC_CD,
NM,
DESC_TXT,
ACTV_IND)
VALUES(
KRIM_PERM_ID_S.nextval,
 sys_guid(),
 1,
 1,
 'KC-NEGOTIATION',
 'GENERATE_NEGOT_SURVEY_NOTIF',
 'MIT Only - Allow user to generate Longitudinal Survey invitation email.',
 'Y'
 )
/