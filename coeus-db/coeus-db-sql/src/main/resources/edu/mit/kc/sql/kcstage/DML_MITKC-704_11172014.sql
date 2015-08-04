declare
	li_count NUMBER;
	li_role_id KRIM_ROLE_T.ROLE_ID%type;
begin
	
	select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'Award Budget Preparer';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'Award Budget Preparer','KC-UNT','Award Budget Preparer','69','Y',sysdate);

		commit;
		
		INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
		select KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,li_role_id,perm_id,'Y' from krim_perm_t where nm in (
		'Maintain KRMS Agenda',
		'Create AwardBudget',
		'Post AwardBudget',
		'Approve AwardBudget',
		'Submit AwardBudget',
		'Blanket Approve AwardBudgetDocument',
		'View AwardBudget',
		'Maintain AwardBudgetRouting',
		'Modify AwardBudget',
		'Use Screen XML Ingester Screen',
		'Unrestricted Document Search',
		'View Other Action List',
		'Use Document Operation Screen',
		'Recall Document',
		'View Award',
		'View Proposal',
		'View Any Proposal'
		);
		
	end if;				
				

	
	update krim_role_mbr_t set  actv_to_dt  = sysdate   
	where mbr_id not in (
	select mbr_id from  krim_role_mbr_t 
	where role_id in (select role_id from KRIM_ROLE_T where ROLE_NM = 'Award Budget Administrator')
	);
	commit;			
								
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('Error while inserting role "Award Budget Preparer". The error is: '||sqlerrm);
END;
/
