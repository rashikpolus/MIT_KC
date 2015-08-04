create or replace TRIGGER t_negot_aft_update_row
after UPDATE on NEGOTIATION for each row
WHEN (
new.NEGOTATION_STATUS_ID = 4 and OLD.NEGOTATION_STATUS_ID <> 4
      )
declare

li_rc                 number;
ls_NegotiationNumber  NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type;
li_AgrrementTypeCode  NEGOTIATION.NEGOTIATION_AGREEMENT_TYPE_ID%type;
ls_UpdateUser         NEGOTIATION.UPDATE_USER%TYPE;
ls_LeadUnit           PROPOSAL_LOG.LEAD_UNIT%type;
li_RightExist         number;
li_count NUMBER;
ls_asso_document NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type;
li_negotiation_id   NEGOTIATION.negotiation_id%type;
begin

    ls_NegotiationNumber := :new.ASSOCIATED_DOCUMENT_ID;
    li_negotiation_id    := :new.negotiation_id;
    li_AgrrementTypeCode := :new.NEGOTIATION_AGREEMENT_TYPE_ID;
        
    
    if li_AgrrementTypeCode <> 12 then
        ls_UpdateUser := :NEW.UPDATE_USER;
        begin
            select lead_unit
            into ls_LeadUnit
            from proposal_log
            where PROPOSAL_NUMBER = ls_NegotiationNumber;
        exception
            when others then
                ls_LeadUnit := '000001';
        end;
        
       -- li_RightExist := FN_user_has_right(ls_UpdateUser, ls_LeadUnit, 'GENERATE_NEGOT_SURVEY_NOTIF');
        
		 --- check whether DESCEND_FLAG is true if li_count > 0 then true else false
		    select count(t1.attr_val) into li_count from krim_role_mbr_attr_data_t t1
			inner join krim_role_mbr_t t2 on t1.role_mbr_id = t2.role_mbr_id
			where t2.role_id = ( Select role_id from  KRIM_ROLE_PERM_T where PERM_ID in (select PERM_ID from KRIM_PERM_T where  upper(NM) = upper('GENERATE_NEGOT_SURVEY_NOTIF')) )
			and   t2.mbr_id in (select prncpl_id from krim_prncpl_t where upper(prncpl_nm) = upper(ls_UpdateUser))
			and  t1.kim_attr_defn_id = 48
			and  t1.attr_val = 'Y' ;
		
			if li_count > 0 then	-- need to check the hierarchy		
				select count(t1.attr_val) into li_count
				from krim_role_prncpl_v t1
				where t1.prncpl_id in ( select prncpl_id from krim_prncpl_t where upper(prncpl_nm) = upper(ls_UpdateUser) )
				and t1.role_id in ( Select role_id from  KRIM_ROLE_PERM_T where PERM_ID in (select PERM_ID from KRIM_PERM_T where  upper(NM) = upper('GENERATE_NEGOT_SURVEY_NOTIF')) )	
				and ls_LeadUnit in ( select unit_number from unit 
								  start with unit_number = t1.attr_val
								  connect by prior unit_number = PARENT_UNIT_NUMBER
								);
			
			else
				select count(*) into li_count
				from krim_role_prncpl_v
				where prncpl_id in ( select prncpl_id from krim_prncpl_t where upper(prncpl_nm) = upper(ls_UpdateUser) )
				and role_id in ( Select role_id from  KRIM_ROLE_PERM_T where PERM_ID in (select PERM_ID from KRIM_PERM_T where  upper(NM) = upper('GENERATE_NEGOT_SURVEY_NOTIF')) )	
				and attr_val= ls_LeadUnit;
			
			
			end if;
		
		
		li_RightExist := 0;
		
		if li_count > 0 then
			li_RightExist := 1;
		end if;	
			
        if li_RightExist = 1  then

            li_rc := kc_long_survey_notif_pkg.fn_gen_long_survey_notif(ls_NegotiationNumber, li_negotiation_id,li_AgrrementTypeCode);
			
        end if;
    end if;

exception
    when others then
        raise_application_error(-20100, 'Error generating notification' || SQLERRM);
  
    
end;
/