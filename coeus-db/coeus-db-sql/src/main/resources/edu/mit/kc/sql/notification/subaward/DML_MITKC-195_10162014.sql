Insert into NOTIFICATION_TYPE (NOTIFICATION_TYPE_ID,MODULE_CODE,ACTION_CODE,DESCRIPTION,SUBJECT,MESSAGE,PROMPT_USER,SEND_NOTIFICATION,UPDATE_USER,UPDATE_TIMESTAMP,VER_NBR,OBJ_ID) values (SEQ_NOTIFICATION_TYPE_ID.NEXTVAL,4,'506','The subaward with MIT listed below has ended.','Subaward from MIT ended','The subaward with MIT listed below has ended. 
<br/><br/<b>Subaward No.:</b>  {PURCHASE_ORDER_NUM}
<br/><b>Period of Performance: </b>    {START_DATE}   - {END_DATE}
<br/><b>Total Amount:</b>   {ANTICIPATED_AMOUNT}
<br/><br/> In accordance with the terms of your Subaward with MIT, you are required to remit several closeout documents described below. Federal Regulations require that we obtain certain information from the Subawardee in order to formally close out specific types of Subawards. Please contact Osp-research-subawards-closeout@mit.edu and provide the required documentation listed below as soon as possible so as not to further delay the payment of the final invoice. Thank you.
<br/><br/>  1.	A Reference of your cumulative invoice which itemizes the cumulative charges under each cost category and verifies the total amount paid under this Subaward, from its inception to completion
<br/><br/> 2.	Executed Release and Assignment Forms, if applicable.
<br/><br/> 3.	A written report of any inventions, discoveries, or patents applied for under the cited Subaward, or a written statement indicating that "there were no inventions or discoveries."
<br/><br/><br/> 4.	The name of all subawardees/subcontractors and your assigned order number for any lower-tier subawards/subcontracts issued which contain a patent rights clause, or a written statement that "there were no such lower-tier subawards/subcontracts," as applicable.
<br/><br/> 5.   listing of any property (equipment, hardware, components, material, etc.) furnished by MIT and/or the Government, or purchased by you under the cited Subaward, which still remains at your facility as residual property to the Subaward, or a written statement that "there is no residual property."  If Not Applicable, please respond as shown above.
<br/><br/> 6.	A Final Technical Report,
</ul><br/><br/> Sincerely,   <br/>Research Subaward Closeout Administrator    <br/>Massachusetts Institute of Technology, Office of Sponsored Programs    <br/>617-253-9694','N','N','admin',sysdate,1,sys_guid())
/
UPDATE NOTIFICATION_TYPE SET SUBJECT = 'Subaward from MIT ended', MESSAGE = 'The subaward with MIT listed below has ended.
<br/><br/<b>Subaward No.:</b>  {PURCHASE_ORDER_NUM}
<br/><b>Period of Performance: </b>    {START_DATE}   - {END_DATE}
<br/><b>Total Amount:</b>   {ANTICIPATED_AMOUNT}
<br/><br/> In accordance with the terms of your Subaward with MIT, you are required to remit several closeout documents described below. Federal Regulations require that we obtain certain information from the Subawardee in order to formally close out specific types of Subawards. Please contact Osp-research-subawards-closeout@mit.edu and provide the required documentation listed below as soon as possible so as not to further delay the payment of the final invoice. Thank you.
<br/><br/>  1.	A Reference of your cumulative invoice which itemizes the cumulative charges under each cost category and verifies the total amount paid under this Subaward, from its inception to completion
<br/><br/> 2.	Executed Release and Assignment Forms, if applicable.
<br/><br/> 3.	A written report of any inventions, discoveries, or patents applied for under the cited Subaward, or a written statement indicating that "there were no inventions or discoveries."
<br/><br/><br/> 4.	The name of all subawardees/subcontractors and your assigned order number for any lower-tier subawards/subcontracts issued which contain a patent rights clause, or a written statement that "there were no such lower-tier subawards/subcontracts," as applicable.
<br/><br/> 5.   listing of any property (equipment, hardware, components, material, etc.) furnished by MIT and/or the Government, or purchased by you under the cited Subaward, which still remains at your facility as residual property to the Subaward, or a written statement that "there is no residual property."  If Not Applicable, please respond as shown above.
<br/><br/> 6.	A Final Technical Report,
</ul><br/><br/> Sincerely,   <br/>Research Subaward Closeout Administrator    <br/>Massachusetts Institute of Technology, Office of Sponsored Programs    <br/>617-253-9694' 
WHERE MODULE_CODE=4 AND ACTION_CODE=505
/
