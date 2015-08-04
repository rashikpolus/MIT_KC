INSERT INTO NOTIFICATION_TYPE (NOTIFICATION_TYPE_ID, MODULE_CODE, ACTION_CODE, DESCRIPTION, SUBJECT, MESSAGE, PROMPT_USER, SEND_NOTIFICATION, UPDATE_USER, UPDATE_TIMESTAMP, VER_NBR, OBJ_ID)
VALUES (SEQ_NOTIFICATION_TYPE_ID.NEXTVAL, (SELECT MODULE_CODE FROM COEUS_MODULE WHERE DESCRIPTION='Development Proposal'), '107','Proposal Person Certification Request Notification for Sponsors in the Hierarchy COI Disclosues with KP Req','Regarding your involvement in Development Proposal {PROPOSAL_TITLE}',
'Hello,<br/>You have been named as a Principal Investigator (PI), Co-Investigator (Co-I) or Senior/Key Person on this proposal:</br>Proposal Number: {PROPOSAL_NUMBER}</br>Sponsor: {SPONSOR_CODE} - {SPONSOR_NAME}<br/>Title:{PROPOSAL_TITLE}<br/>Principal Investigator: {PRINCIPAL INVESTIGATOR}<br/>Administrator preparing proposal: {AGGREGATOR}<br/>
In order to meet federal requirements and MIT policies and to ensure objectivity in research, please click the link below and proceed to a short series of questions; these questions constitute the PI Certification and Disclosure for this proposal. The proposal cannot begin routing for approval until all certifications are complete.<br/><br/><br/>
<a href="{CERT_PAGE}" target="_blank">{CERT_PAGE}</a><br/><br/>Principal Investigators and Co-Investigators:</br><br/>You will be asked to answer several short (yes/no) questions about the proposal and three screening questions related to conflict of interest. If the answers to the screening questions do not indicate a need for additional information, your certification and disclosure is complete. If additional information is needed,
you will be directed to the My COI module of Coeus Lite to complete a full financial disclosure related to this proposal. Note: Please read Sponsored Travel info below.<br/><br/>Senior/Key Personnel:<br/><br/>You will be asked to answer three short screening questions (yes/no) related to conflict of interest. If the answers to the screening questions do not indicate a need for additional information,
your certification and disclosure is complete. If additional information is needed, you will be directed to the My COI module of Coeus Lite to complete a full financial disclosure related to this proposal. Note: Please read Sponsored Travel info below.<br/>Sponsored Travel disclosures:<br/><br/>This proposal is to be funded by either NIH, a Public Health Service (PHS) agency or a sponsor adopting PHS regulations. As such you must disclose any Sponsored Travel if the amount equals or exceeds
$5,000, alone or in combination with other Remuneration and Equity Interests from any one entity at the time of submission of this proposal, looking back over the previous 12 months.<br/><br/>Sponsored Travel is defined as (a) travel expenses paid to an Investigator or travel paid on an Investigators behalf, by a single entity in any 12-month period and (b) travel reimbursed to 
or paid on behalf of an Investigators Family by a single entity in any 12-month period, ONLY if such travel reasonably appears to be related to the Investigators Institutional Responsibilities.<br/><br/>You do not need to disclose Sponsored Travel paid for or reimbursed by:<br/>&bull; MIT (e.g. paid from MIT funds or from sponsored awards, funds, grants managed at MIT)</br> 
&bull; U.S. Federal, state or local governmental agencies</br>&bull; U.S. Institutes of higher education</br>&bull; U.S. Research institutions affiliated with institutions of higher education</br>&bull; U.S. Academic teaching hospitals and medical centers<br/><br/><br/><br/>To disclose Sponsored Travel, go to <a href="{LINK_TO_COI}" target="_blank">{LINK_TO_COI}</a> and under "Create" click on the Travel Disclosures (PHS only) button to begin. You can disclose travel at any time within 30 days of completion of or reimbursement for a trip.<br/><br/> 
You must have an MIT certification to complete this action. <a href="http://ist.mit.edu/certificates" target="_blank"/>http://ist.mit.edu/certificates</a><br/><br/>If you have questions, please contact the administrator who is preparing this proposal.<br/><br/>Thank you.<br/><br/><br/><br/>Kuali Coeus and Coeus Lite require an MIT personal web certificate.<br/> 
For information about obtaining MIT personal web certificate please go to <a href="http://ist.mit.edu/certificates" target="_blank"/>http://ist.mit.edu/certificates</a>','N', 'Y', 'admin', SYSDATE, 1, SYS_GUID())
/
UPDATE NOTIFICATION_TYPE SET MESSAGE='Hello,<br/>You have been named as a Principal Investigator (PI), Co-Investigator (Co-I) or Senior/Key Person on this proposal:</br>Proposal Number: {PROPOSAL_NUMBER}</br>
Sponsor: {SPONSOR_CODE} - {SPONSOR_NAME}<br/>Title:{PROPOSAL_TITLE}<br/>Principal Investigator: {PRINCIPAL INVESTIGATOR}<br/>Administrator preparing proposal: {AGGREGATOR}<br/>
In order to meet federal requirements and MIT policies and to ensure objectivity in research, please click the link below and proceed to a short series of questions; these questions
constitute the PI Certification and Disclosure for this proposal. The proposal cannot begin routing for approval until all certifications are complete.<br/><br/><br/>
<a href="{CERT_PAGE}" target="_blank">{CERT_PAGE}</a><br/><br/>Principal Investigators and Co-Investigators:</br><br/>
You will be asked to answer several short (yes/no) questions about the proposal and three screening questions related to conflict of interest.
If the answers to the screening questions do not indicate a need for additional information, your certification and disclosure is complete. If additional information is needed,
you will be directed to the My COI module of Coeus Lite to complete a full financial disclosure related to this proposal.<br/><br/>
You must have an MIT certification to complete this action. <a href="http://ist.mit.edu/certificates" target="_blank"/>http://ist.mit.edu/certificates</a><br/><br/>If you have questions, please contact the administrator who is preparing this proposal. .<br/><br/>Thank you.<br/><br/><br/><br/>Kuali Coeus and Coeus Lite require an MIT personal web certificate.<br/> 
For information about obtaining MIT personal web certificate please go to <a href="http://ist.mit.edu/certificates" target="_blank"/>http://ist.mit.edu/certificates</a>' 
WHERE MODULE_CODE= (SELECT MODULE_CODE FROM COEUS_MODULE WHERE DESCRIPTION='Development Proposal') AND ACTION_CODE='104'
/