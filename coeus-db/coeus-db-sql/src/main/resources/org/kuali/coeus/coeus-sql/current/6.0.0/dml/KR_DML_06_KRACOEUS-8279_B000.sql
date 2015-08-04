set define off
/
update notification_type set message='Please review the following proposal by clicking on Proposal Number. Please answer the certification questions if you agree to participate in this project. Proposal Details as follows:<br/>Document Number: {DOCUMENT_NUMBER}<br/>Proposal Number: <a title="" target="_self" href="{APP_LINK_PREFIX}/kc-pd-krad/proposalDevelopment?methodToCall=viewUtility&amp;viewId=PropDev-CertificationView&amp;docId={DOCUMENT_NUMBER}&amp;userName={USER_NAME}">{PROPOSAL_NUMBER}</a> <br/>Proposal Title: {PROPOSAL_TITLE}<br/>Principal Investigator: {PRINCIPAL INVESTIGATOR}
  <br/>Lead Unit: {LEAD_UNIT} - {LEAD_UNIT_NAME}<br/>Sponsor: {SPONSOR_CODE} - {SPONSOR_NAME}<br/>Dealine Date: {DEADLINE_DATE}' where module_code=3 and  action_code=104
  /
  
  