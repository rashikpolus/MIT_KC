--
-- T_DISCL_AFT_INSERT_ROW  (Trigger) 
--
CREATE OR REPLACE TRIGGER t_nda_survey_aft_update_row
after UPDATE on NDA for each row
declare

li_rc                 number;
ls_responseId  varchar2(50);
ls_NDANumber  NDA.NDA_NUMBER%type;
ls_PIID  NDA.PERSON_ID%type;
ls_Title NDA.TITLE%type;
ls_OrgName NDA.ORGANIZATION_NAME%type;

begin

    ls_responseId := :new.SURVEY_ID;
    ls_NDANumber := :new.NDA_NUMBER;
    
    ls_PIID  := :new.PERSON_ID;
    ls_Title := :new.TITLE;
    ls_OrgName := :new.ORGANIZATION_NAME;
    
    li_rc := fn_gen_nda_survey_compl_notif(ls_NDANumber, ls_PIID, ls_Title, ls_OrgName, ls_responseId  );

exception
    when others then
        raise_application_error(-20100, 'Error generating notification' || SQLERRM);

end;
/