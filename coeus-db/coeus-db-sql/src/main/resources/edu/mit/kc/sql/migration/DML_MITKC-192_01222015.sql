update NOTIFICATION_TYPE
set MESSAGE = 'A new subaward has been added to the award listed below.  If you have not already done so, please create an SAP requisition as soon as possible.  Contact the Research Subawards Team at osp-research-subawards@mit.edu with the requisition number, the Final Statement of Work and the Final Budget for the subawardee.
<br/><br/><br/><br/><br/><b>Subawardee Name:</b>     {SUBCONTRACT_NAME} 
<br/><b>Subaward Amount: </b>    {AMOUNT} 
<br/><b>Sponsor Award No.: </b>  {SPONSOR_AWARD_NUMBER}
<br/><b>Award Type: </b>         {AWARD_TYPE}
<br/><b>Account No.: </b>        {ACCOUNT_NUMBER}
<br/><b>Title: </b>              {TITLE}
<br/><b>PI: </b>                 {PERSON_NAME}
<br/><b>Lead Unit: </b>          {UNIT_NUMBER} - {UNIT_NAME}'
WHERE MODULE_CODE = 4
AND ACTION_CODE = '501'
/
update NOTIFICATION_TYPE
set MESSAGE = 'The subaward amount entered on the award listed below has been updated.  Please create an SAP requisition as soon as possible to add the additional funding.  Contact the Research Subawards Team at osp-research-subawards@mit.edu with the requisition number.
<br/><br/><br/><br/><br/><b>Subawardee Name:</b>     {SUBCONTRACT_NAME} 
<br/><b>Subaward Amount: </b>    {AMOUNT} 
<br/><b>Sponsor Award No.: </b>  {SPONSOR_AWARD_NUMBER}
<br/><b>Award Type: </b>         {AWARD_TYPE}
<br/><b>Account No.: </b>         {ACCOUNT_NUMBER} 
<br/><b>Title: </b>               {TITLE}
<br/><b>PI: </b>                  {PERSON_NAME}
<br/><b>Lead Unit: </b>       {UNIT_NUMBER} - {UNIT_NAME}'
WHERE MODULE_CODE = 4
AND ACTION_CODE = '502'
/
update NOTIFICATION_TYPE
set MESSAGE = 'The End Date of the Subaward listed below indicates it is ending in 30 days.  If this subaward will continue please create an SAP requisition as soon as possible.  Contact the Research Subawards Team at osp-research-subawards@mit.edu with the requisition number.
<br/><br/<b>Subawardee Name: </b>  {ORGANIZATION_NAME}
<br/><b>Subaward End Date: </b> {END_DATE}  
<br/><b>Subaward No.: </b> {PERCHASE_ORDER_NUM}  
<br/><b>Sponsor Award No.: </b> {SPONSOR_AWARD_NUMBER}  
<br/><b>Account No.: </b> {ACCOUNT_NUMBER} 
<br/><br/> If you are waiting for a modification from the sponsor and are not able to create the SAP requisition at this time, please notify the Research Subawards Team at osp-research-subawards@mit.edu  - otherwise the closeout process will commence on the current subaward end date.
<br/><br/> If this subaward is not continuing please complete the Subawardee Closeout Checklist found here: http://osp.mit.edu/coeus/help-and-training/rst-subaward-checklist-dlc-pi .Follow the instructions and submit.'
WHERE MODULE_CODE = 4
AND ACTION_CODE = '503'
/
update NOTIFICATION_TYPE
set MESSAGE = 'The End Date of the Subaward listed below indicates it is ending in 30 days.  If this subaward will continue please create an SAP requisition as soon as possible.  Contact the Research Subawards Team at osp-research-subawards@mit.edu with the requisition number.
<br/><br/<b>Subawardee Name: </b>  {ORGANIZATION_NAME}  
<br/><b>Subaward End Date: </b> {END_DATE}   
<br/><b>Subaward No.: </b> {PERCHASE_ORDER_NUM}  
<br/><b>Sponsor Award No.: </b>    
<br/><b>Account No.: </b>    
<br/><br/> If you are waiting for a modification from the sponsor and are not able to create the SAP requisition at this time, please notify the Research Subawards Team at osp-research-subawards@mit.edu  - otherwise the closeout process will commence on the current subaward end date.
<br/><br/> If this subaward is not continuing please complete the Subawardee Closeout Checklist found here: http://osp.mit.edu/coeus/help-and-training/rst-subaward-checklist-dlc-pi .  Follow the instructions and submit.'
WHERE MODULE_CODE = 4
AND ACTION_CODE = '504'
/
update NOTIFICATION_TYPE
set MESSAGE = '<br/><br/<b>Subaward No.: </b>  {PURCHASE_ORDER_NUM}  
<br/><b>Period of Performance: </b>    {START_DATE} - {END_DATE}  
<br/><b>Total Amount: </b>   {ANTICIPATED_AMOUNT} 
<br/><br/> In accordance with the terms of your Subaward with MIT, you are required to remit several closeout documents described below. Federal Regulations require that we obtain certain information from the Subawardee in order to formally close out specific types of Subawards. Please contact Osp-research-subawards-closeout@mit.edu and provide the required documentation listed below as soon as possible so as not to further delay the payment of the final invoice. Thank you.
<br/><br/>  1.	A Reference of your cumulative invoice which itemizes the cumulative charges under each cost category and verifies the total amount paid under this Subaward, from its inception to completion
<br/><br/> 2.	Executed Release and Assignment Forms, if applicable. 
<br/><br/> 3.	A written report of any inventions, discoveries, or patents applied for under the cited Subaward, or a written statement indicating that "there were no inventions or discoveries."
<br/><br/><br/> 4.	The name of all subawardees/subcontractors and your assigned order number for any lower-tier subawards/subcontracts issued which contain a patent rights clause, or a written statement that "there were no such lower-tier subawards/subcontracts," as applicable.
<br/><br/> 5.   listing of any property (equipment, hardware, components, material, etc.) furnished by MIT and/or the Government, or purchased by you under the cited Subaward, which still remains at your facility as residual property to the Subaward, or a written statement that "there is no residual property."  If Not Applicable, please respond as shown above.
<br/><br/> 6.	A Final Technical Report,
</ul><br/><br/> Sincerely,   <br/>Research Subaward Closeout Administrator    <br/>Massachusetts Institute of Technology, Office of Sponsored Programs    <br/>617-253-9694'
WHERE MODULE_CODE = 4
AND ACTION_CODE = '505'
/
commit
/
