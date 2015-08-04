create or replace
function fn_generate_master_sap_feed
					(as_path VARCHAR2,
					as_update_user VARCHAR2)
return varchar2 is
li_batch_id 				SAP_FEED_BATCH_LIST.BATCH_ID%TYPE;
ld_now						DATE;
ret_sap						number;
ret_sap_bud					number;
ret 						varchar2(30);
begin	
	
	SELECT seq_sap_batch_id.NEXTVAL, sysdate
	INTO li_batch_id, ld_now
	FROM DUAL;
		
	begin
		ret_sap := fn_generate_sap_feed(as_path,as_update_user,li_batch_id,ld_now);
	exception
	when others then
		raise_application_error(-20100, 'Exception in fn_generate_sap_feed. Error is ' || SQLERRM);
		ret_sap := -1;
	end;	
	
	begin
		ret_sap_bud := fn_generate_sap_budget_feed(as_path,as_update_user,li_batch_id,ld_now);
	exception
	when others then
		raise_application_error(-20101, 'Exception in fn_generate_sap_budget_feed. Error is ' || SQLERRM);
		ret_sap_bud := -1;
	end;
	ret := ret_sap||','||ret_sap_bud;
	
	return ret;

end;
/