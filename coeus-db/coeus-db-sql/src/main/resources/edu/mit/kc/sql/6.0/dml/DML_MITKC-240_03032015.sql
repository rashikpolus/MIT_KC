UPDATE notification_type set message = 'Proposal Person Certification completed by Proxy.  Proposal Details as follows:<br/>Document Number: {DOCUMENT_NUMBER}<br/>Proposal Number: {PROPOSAL_NUMBER}<br/>Proposal Title: {PROPOSAL_TITLE}<br/>Created For: {PRINCIPAL INVESTIGATOR}<br/>Lead Unit: {LEAD_UNIT} - {LEAD_UNIT_NAME}<br/>Sponsor: {SPONSOR_CODE} - {SPONSOR_NAME}<br/>Certify By: {PROPOSAL_CERTIFY_USER}<br/>Certified On: {PROPOSAL_CERTIFY_TIME_STAMP}<br/><br/>Kuali Coeus requires an MIT personal web certificate.<br/>For information about obtaining MIT personal web certificate please go to https://ca.mit.edu/ca/'
WHERE module_code = 3
AND action_code = 106
/
commit
/
