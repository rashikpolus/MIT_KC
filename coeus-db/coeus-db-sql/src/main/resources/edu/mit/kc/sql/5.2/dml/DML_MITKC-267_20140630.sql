-- commented because already inserting in different file "DML_MITKC-199_B000.sql"
--insert into KRMS_TYP_T(TYP_ID,NM,NMSPC_CD,SRVC_NM,ACTV,VER_NBR) 
--	values ('KCMIT1001','MIT Custom Propdev Java Function Term Service','KC-PD','mitPropDevJavaFunctionKrmsTermService','Y',1)
--/
insert into KRMS_FUNC_T (FUNC_ID,NM,DESC_TXT,RTRN_TYP,VER_NBR,ACTV,TYP_ID,NMSPC_CD) 
	values (CONCAT('KCMIT', KRMS_FUNC_S.NEXTVAL),'budgetPeriodAmountRule','Check if the total cost in any budget period is over 2 Million','java.lang.String',1,'Y',
		(select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-PD' and NM = 'MIT Custom Propdev Java Function Term Service'),'KC-PD')
/
insert into KRMS_FUNC_PARM_T (FUNC_PARM_ID,FUNC_ID,NM,DESC_TXT,TYP,SEQ_NO) 
	values (CONCAT('KCMIT', KRMS_FUNC_PARM_S.NEXTVAL),(select FUNC_ID from KRMS_FUNC_T where  NM='budgetPeriodAmountRule' and NMSPC_CD='KC-PD'),
			'DevelopmentProposal','DevelopmentProposal bo','org.kuali.kra.proposaldevelopment.bo.DevelopmentProposal',1)
/
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NMSPC_CD, NM, DESC_TXT, TYP, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL),'KC-PD',(select FUNC_ID from KRMS_FUNC_T where  NM='budgetPeriodAmountRule' and NMSPC_CD='KC-PD'),
			'Check if the total cost in any budget period is over 2 Million','java.lang.String','Y',1)
/
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
	values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL),(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and  NM=(select FUNC_ID from KRMS_FUNC_T where  NM='budgetPeriodAmountRule' and NMSPC_CD='KC-PD')),
			1,'Check if the total cost in any budget period is over 2 Million')
/
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
	values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL),'KC-PD-CONTEXT',(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='budgetPeriodAmountRule' and NMSPC_CD='KC-PD')),'Y')
/
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) 
	values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='budgetPeriodAmountRule' and NMSPC_CD='KC-PD')), 
			(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Function'))
/
insert into KRMS_TERM_RSLVR_T (TERM_RSLVR_ID, NMSPC_CD, NM, TYP_ID, OUTPUT_TERM_SPEC_ID, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_RSLVR_S.NEXTVAL),'KC-PD','Total Cost Over 2 Million Check Resolver',
			(select TYP_ID from KRMS_TYP_T where NM='Function Term Resolver Type Service' and NMSPC_CD='KC-KRMS'),
			(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='budgetPeriodAmountRule' and NMSPC_CD='KC-PD')),'Y',1)
/
