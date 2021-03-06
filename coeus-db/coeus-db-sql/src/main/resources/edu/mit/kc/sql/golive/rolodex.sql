ALTER TABLE SPONSOR DISABLE CONSTRAINT FK_SPONSOR_ROLODEX_KRA 
/
ALTER TABLE AWARD_TEMPL_REP_TERMS_RECNT DISABLE CONSTRAINT FK1_AWD_TEMPL_REP_TERMS_RECNT 
/
ALTER TABLE AWARD_REP_TERMS_RECNT DISABLE CONSTRAINT FK3_AWARD_REP_TERMS_RECNT 
/
ALTER TABLE PROPOSAL DISABLE CONSTRAINT FK_PROPOSAL_ROLODEX_ID 
/
ALTER TABLE PROTOCOL_REVIEWERS DISABLE CONSTRAINT FK_PROTOCOL_REVIEWERS5 
/
ALTER TABLE PROTOCOL_VOTE_ABSTAINEES DISABLE CONSTRAINT FK_PROTOCOL_VOTE_ABST_FK3 
/
ALTER TABLE SUBAWARD_CONTACT DISABLE CONSTRAINT FK_SUBAWARD_CONTACT_ROLODEX 
/
ALTER TABLE PROTOCOL_VOTE_RECUSED DISABLE CONSTRAINT FK_PROTOCOL_VOTE_RECUSED_FK3 
/
ALTER TABLE AWARD_TEMPLATE_CONTACT DISABLE CONSTRAINT FK_AWD_TEMPL_CONT_ROLODEX_ID 
/
ALTER TABLE EPS_PROP_LOCATION DISABLE CONSTRAINT FK_EPS_PROP_LOCATION_RLDEX_KRA 
/
ALTER TABLE KREW_PPL_FLW_DLGT_T DISABLE CONSTRAINT KREW_PPL_FLW_DLGT_FK1
/
delete from rolodex
/
INSERT INTO rolodex(
rolodex_id,
last_name,
first_name,
middle_name,
suffix,
prefix,
title,
organization,
address_line_1,
address_line_2,
address_line_3,
fax_number,
email_address,
city,
county,
state,
postal_code,
comments,
phone_number,
country_code,
sponsor_code,
owned_by_unit,
sponsor_address_flag,
delete_flag,
create_user,
update_timestamp,
update_user,
ver_nbr,
obj_id,
actv_ind
)
SELECT 
rolodex_id,
last_name,
first_name,
middle_name,
suffix,
prefix,
title,
organization,
address_line_1,
address_line_2,
address_line_3,
fax_number,
email_address,
city,
county,
state,
postal_code,
comments,
phone_number,
country_code,
sponsor_code,
owned_by_unit,
sponsor_address_flag,
delete_flag,
create_user,
update_timestamp,
update_user,
ver_nbr,
obj_id,
actv_ind
FROM rolodex@kc_stag_db_link
/
DECLARE
ls_max_val NUMBER(6,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
BEGIN

  SELECT MAX(rolodex_id) INTO ls_max_val FROM rolodex;
  IF ls_max_val IS NULL THEN
  ls_max_val := 0;
  END IF;    
  SELECT SEQ_ROLODEX_ID.nextval INTO li_present_seq_val FROM dual;
  IF li_present_seq_val < ls_max_val THEN  
    li_increment := ls_max_val - li_present_seq_val;  
    EXECUTE IMMEDIATE('alter sequence SEQ_ROLODEX_ID increment by '||li_increment);
    SELECT SEQ_ROLODEX_ID.nextval INTO li_present_seq_val FROM DUAL;   
    EXECUTE IMMEDIATE('alter sequence SEQ_ROLODEX_ID increment by 1');
  END IF;

END;
/
ALTER TABLE SPONSOR ENABLE CONSTRAINT FK_SPONSOR_ROLODEX_KRA 
/
ALTER TABLE AWARD_TEMPL_REP_TERMS_RECNT ENABLE CONSTRAINT FK1_AWD_TEMPL_REP_TERMS_RECNT 
/
ALTER TABLE AWARD_REP_TERMS_RECNT ENABLE CONSTRAINT FK3_AWARD_REP_TERMS_RECNT 
/
ALTER TABLE PROPOSAL ENABLE CONSTRAINT FK_PROPOSAL_ROLODEX_ID 
/
ALTER TABLE PROTOCOL_REVIEWERS ENABLE CONSTRAINT FK_PROTOCOL_REVIEWERS5 
/
ALTER TABLE PROTOCOL_VOTE_ABSTAINEES ENABLE CONSTRAINT FK_PROTOCOL_VOTE_ABST_FK3 
/
ALTER TABLE SUBAWARD_CONTACT ENABLE CONSTRAINT FK_SUBAWARD_CONTACT_ROLODEX 
/
ALTER TABLE PROTOCOL_VOTE_RECUSED ENABLE CONSTRAINT FK_PROTOCOL_VOTE_RECUSED_FK3 
/
ALTER TABLE AWARD_TEMPLATE_CONTACT ENABLE CONSTRAINT FK_AWD_TEMPL_CONT_ROLODEX_ID 
/
ALTER TABLE EPS_PROP_LOCATION ENABLE CONSTRAINT FK_EPS_PROP_LOCATION_RLDEX_KRA 
/
ALTER TABLE KREW_PPL_FLW_DLGT_T ENABLE CONSTRAINT KREW_PPL_FLW_DLGT_FK1
/