UPDATE NOTIFICATION_TYPE SET SUBJECT = 'Subaward amount updated', MESSAGE = 'The subaward amount entered on the award listed below has been updated.Please create an SAP requisition as soon as possible to add the additional funding.  Contact the Research Subawards Team at osp-research-subawards@mit.edu with the requisition number. 
<br/><br/><br/><br/><br/><b>Subawardee Name:</b>{SUBCONTRACT_NAME}  
<br/><b>Subaward Amount:</b>{AMOUNT}  
<br/><b>Sponsor Award No.:</b>{SPONSOR_AWARD_NUMBER} 
<br/><b>Award Type:</b>{AWARD_TYPE} 
<br/><b>Account No.:</b>{ACCOUNT_NUMBER}  
<br/><b>Title:</b>{TITLE} 
<br/><b>PI:</b>{PERSON_NAME} 
<br/><b>Lead Unit:</b>{UNIT_NAME}' 
WHERE MODULE_CODE=4 AND ACTION_CODE=502
/

