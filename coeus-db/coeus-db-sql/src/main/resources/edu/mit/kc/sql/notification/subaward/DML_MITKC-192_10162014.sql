UPDATE NOTIFICATION_TYPE SET SUBJECT = 'New subaward entered', MESSAGE = 'A new subaward has been added to the award listed below.
If you have not already done so, please create an SAP requisition as soon as possible.
Contact the Research Subawards Team at osp-research-subawards@mit.edu with the requisition number, the Final Statement of Work and the Final Budget for the subawardee. 
<br/><br/><br/><br/><br/><b>Subawardee Name:</b>{SUBCONTRACT_NAME}  
<br/><b>Subaward Amount:</b>{AMOUNT}  
<br/><b>Sponsor Award No.:</b>{SPONSOR_AWARD_NUMBER} 
<br/><b>Award Type:</b>{AWARD_TYPE} 
<br/><b>Account No.:</b>{ACCOUNT_NUMBER} 
<br/><b>Title:</b>{TITLE} 
<br/><b>PI:</b>{PERSON_NAME} 
<br/><b>Lead Unit:</b>{UNIT_NAME}' 
WHERE MODULE_CODE=4 AND ACTION_CODE=501
/
