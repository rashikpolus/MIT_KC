CREATE OR REPLACE
FUNCTION fn_prop_person_coi_status(
AS_PROPOSAL VARCHAR2,
AS_PERSON_ID VARCHAR2,
AS_IS_QNR_COMPLD NUMBER
) RETURN VARCHAR2 IS
ls_inst_proposal_number VARCHAR2(8);
ls_dev_proposal_number VARCHAR2(8);
ls_module_item_key osp$coi_disclosure.module_item_key%type;
ls_status VARCHAR2(32);
ls_msg VARCHAR2(14) := 'Not Disclosed';
BEGIN

	IF AS_IS_QNR_COMPLD = 0 THEN -- Not PPC certification completed
		RETURN ls_msg;
	END IF;	

	ls_dev_proposal_number := trim(to_char(AS_PROPOSAL,'00000000')) ;
	
	BEGIN
		SELECT t1.proposal_number into ls_inst_proposal_number
		FROM PROPOSAL@MITKC.MIT.EDU t1 
		INNER JOIN PROPOSAL_ADMIN_DETAILS@MITKC.MIT.EDU t2 on t1.PROPOSAL_ID = t2.INST_PROPOSAL_ID
		WHERE t2.DEV_PROPOSAL_NUMBER = AS_PROPOSAL;
		
		ls_module_item_key := ls_inst_proposal_number;
		
	EXCEPTION
	WHEN OTHERS THEN
		ls_module_item_key := ls_dev_proposal_number;
	END;

	BEGIN
		select
		decode( cd.disclosure_disposition_code,3,decode(cd.review_status_code, 1,'In-Progress','Submitted For Review'),1,'Approved','Disapproved') into ls_status
		from osp$coi_disclosure cd
		where cd.module_item_key = ls_module_item_key
		and   cd.person_id = as_person_id
		and   cd.sequence_number = ( select max(cdd.sequence_number)  from osp$coi_disc_details cdd
									where  cdd.module_item_key = cd.module_item_key
									AND cdd.coi_disclosure_number = cd.coi_disclosure_number
									);
	EXCEPTION
		WHEN OTHERS THEN
		RETURN ls_msg;
	END;
	
	RETURN ls_status;

END;
/
