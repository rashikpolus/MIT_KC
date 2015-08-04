set define off;
declare
li_count pls_integer;
begin
	select count(notification_type_id) into li_count from NOTIFICATION_TYPE where MODULE_CODE = 2 and action_code = 575;
	if li_count = 0 then
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
		2,
		'575',
		'List of Proposals Deactivated',
		'Deactivate script run on',
		'List of Proposals Deactivated<br/><br/> 
		<table border="1"> 
		<tr> 
		<th>PROPOSAL NUMBER&nbsp; &nbsp; &nbsp; </th> 
		<th>TITLE&nbsp; &nbsp; &nbsp;  </th> 
		</tr> 
		{LIST}
		</table>',
		'N',
		'Y',
		USER,
		sysdate,
		1,
		sys_guid()
		);
	end if;
end;
/