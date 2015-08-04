UPDATE NOTIFICATION_TYPE SET MESSAGE='Hello,<br/>You have been named as a Principal Investigator (PI), Co-Investigator (Co-I) or Senior/Key Person on this proposal:</br>Proposal Number: {PROPOSAL_NUMBER}</br>
Sponsor: {SPONSOR_CODE} - {SPONSOR_NAME}<br/>Title:{PROPOSAL_TITLE}<br/>Principal Investigator: {PRINCIPAL INVESTIGATOR}<br/>Administrator preparing proposal: {AGGREGATOR}<br/><br/>
In order to meet federal requirements and MIT policies and to ensure objectivity in research, please click the link below and proceed to a short series of questions; these questions
constitute the PI Certification and Disclosure for this proposal. The proposal cannot begin routing for approval until all certifications are complete.<br/><br/><br/>
<a href="{CERT_PAGE}" target="_blank">{CERT_PAGE}</a><br/><br/>Principal Investigators and Co-Investigators:</br><br/>
You will be asked to answer several short (yes/no) questions about the proposal and three screening questions related to conflict of interest.
If the answers to the screening questions do not indicate a need for additional information, your certification and disclosure is complete. If additional information is needed,
you will be directed to the My COI module of Coeus Lite to complete a full financial disclosure related to this proposal.<br/><br/>
You must have an MIT certification to complete this action. <a href="http://ist.mit.edu/certificates" target="_blank"/>http://ist.mit.edu/certificates</a><br/><br/>If you have questions, please contact the administrator who is preparing this proposal.<br/><br/>Thank you.<br/><br/><br/><br/>Kuali Coeus and Coeus Lite require an MIT personal web certificate.<br/> 
For information about obtaining MIT personal web certificate please go to <a href="http://ist.mit.edu/certificates" target="_blank"/>http://ist.mit.edu/certificates</a>' 
WHERE MODULE_CODE= (SELECT MODULE_CODE FROM COEUS_MODULE WHERE DESCRIPTION='Development Proposal') AND ACTION_CODE='104'
/
