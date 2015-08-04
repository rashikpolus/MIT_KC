--inserting parameter to KRCR_PARM_T
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) 
values ('KC-GEN','All','DEFAULT_ORGANIZATION_ID',SYS_GUID(),1,'CONFG','000001','Sets default organization id','A','KUALI')
/
--    public String checkNonMITOrg(DevelopmentProposal developmentProposal);
insert into KRMS_FUNC_T 
	(FUNC_ID,NM,DESC_TXT,RTRN_TYP,VER_NBR,ACTV,
		TYP_ID,NMSPC_CD) 
	values (CONCAT('KCMIT', KRMS_FUNC_S.NEXTVAL),'checkNonMITOrg','Check Non MIT Org','java.lang.String',1,'Y',
		(select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-PD' and NM = 'MIT Custom Propdev Java Function Term Service'),'KC-PD')
/
insert into KRMS_FUNC_PARM_T (FUNC_PARM_ID,FUNC_ID,NM,DESC_TXT,TYP,SEQ_NO) 
	values (CONCAT('KCMIT', KRMS_FUNC_PARM_S.NEXTVAL),(select FUNC_ID from KRMS_FUNC_T where  NM='checkNonMITOrg' and NMSPC_CD='KC-PD'),
			'DevelopmentProposal','DevelopmentProposal bo','org.kuali.kra.proposaldevelopment.bo.DevelopmentProposal',1)
/
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NMSPC_CD, NM, DESC_TXT, TYP, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL),'KC-PD',(select FUNC_ID from KRMS_FUNC_T where  NM='checkNonMITOrg' and NMSPC_CD='KC-PD'),
			'Check Non MIT Org','java.lang.String','Y',1)
/
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
	values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL),(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and  NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkNonMITOrg' and NMSPC_CD='KC-PD')),
			1,'Check Non MIT Org')
/
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
	values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL),'KC-PD-CONTEXT',(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkNonMITOrg' and NMSPC_CD='KC-PD')),'Y')
/
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) 
	values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkNonMITOrg' and NMSPC_CD='KC-PD')), 
			(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Function'))
/
insert into KRMS_TERM_RSLVR_T (TERM_RSLVR_ID, NMSPC_CD, NM, TYP_ID, OUTPUT_TERM_SPEC_ID, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_RSLVR_S.NEXTVAL),'KC-PD','Non MIT Org Check Resolver',
			(select TYP_ID from KRMS_TYP_T where NM='Function Term Resolver Type Service' and NMSPC_CD='KC-KRMS'),
			(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkNonMITOrg' and NMSPC_CD='KC-PD')),'Y',1)
/