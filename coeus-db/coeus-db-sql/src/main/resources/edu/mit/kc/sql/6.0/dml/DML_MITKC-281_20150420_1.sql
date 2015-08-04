-- FN_check_disc_done_rule(DevelopmentProposal developmentProposal);    
update KRMS_FUNC_PARM_T set TYP='org.kuali.coeus.propdev.impl.core.DevelopmentProposal' where TYP='org.kuali.kra.proposaldevelopment.bo.DevelopmentProposal'
/
update KRMS_FUNC_T set TYP_ID = (select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-KRMS' and NM = 'Stored Function Term Resolver Type Service') WHERE NM = 'FN_check_disc_done_rule'
/
delete from KRMS_TERM_RSLVR_T where NMSPC_CD='KC-PD' and nm='Disclosures for a proposal have been submitted Check Resolver'
/
delete from KRMS_TERM_SPEC_CTGRY_T where TERM_SPEC_ID=(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-PD'))
/
delete from KRMS_CNTXT_VLD_TERM_SPEC_T where TERM_SPEC_ID=(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-PD'))
/
delete from KRMS_TERM_T where TERM_SPEC_ID=(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and  NM=(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-PD'))
/
delete from KRMS_FUNC_PARM_T where FUNC_ID=(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-PD')  
/
delete from KRMS_TERM_SPEC_T where nm =(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-PD') and 		DESC_TXT='Check if all disclosures for a proposal have been submitted'
/
delete from KRMS_FUNC_T where nm='FN_check_disc_done_rule' and DESC_TXT='Check if all disclosures for a proposal have been submitted'
/
update KRMS_TERM_SPEC_T set NMSPC_CD='KC-PD' where NMSPC_CD = 'KC-KRMS' and NM=(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-KRMS')
/
update KRMS_FUNC_T set  NMSPC_CD='KC-PD' where NMSPC_CD = 'KC-KRMS' and nm='FN_check_disc_done_rule' and  DESC_TXT='Check if all disclosures for a proposal have been submitted'
/
insert into KRMS_FUNC_T 
	(FUNC_ID,NM,DESC_TXT,RTRN_TYP,VER_NBR,ACTV,
		TYP_ID,NMSPC_CD) 
	values (CONCAT('KCMIT', KRMS_FUNC_S.NEXTVAL),'FN_check_disc_done_rule','Check if all disclosures for a proposal have been submitted','java.lang.String',1,'Y',
		(select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-KRMS' and NM = 'Stored Function Term Resolver Type Service'),'KC-PD')
/
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NMSPC_CD, NM, DESC_TXT, TYP, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL),'KC-PD',(select FUNC_ID from KRMS_FUNC_T where  NM='FN_check_disc_done_rule' and NMSPC_CD='KC-PD'),
			'Check if all disclosures for a proposal have been submitted','java.lang.String','Y',1)
/

