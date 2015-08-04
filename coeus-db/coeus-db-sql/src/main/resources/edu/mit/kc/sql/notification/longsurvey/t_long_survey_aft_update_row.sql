create or replace
TRIGGER t_long_survey_aft_update_row
after UPDATE on LONG_SURVEY_NOTIF for each row
declare

li_rc                 number;
ls_responseId  varchar2(50);
ls_NegotiationNumber  NEGOTIATION.NEGOTIATION_ID%type;
ls_asso_document NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type;
begin

    ls_responseId := :new.SURVEY_ID;
    ls_NegotiationNumber := :new.NEGOTIATION_ID;
    
	begin
	select ASSOCIATED_DOCUMENT_ID into ls_asso_document  from NEGOTIATION where NEGOTIATION_ID = ls_NegotiationNumber;
	exception
	when others then
	ls_asso_document := null;
	end;
	
	if ls_asso_document is not null then
		li_rc := kc_long_survey_notif_pkg.fn_gen_long_survey_compl_notif(ls_asso_document,ls_responseId );
	end if;

exception
    when others then
        raise_application_error(-20100, 'Error generating notification' || SQLERRM);

end;
/