--    public String allAwards(Award Award,String questionId);
insert into KRMS_FUNC_T
	(FUNC_ID,NM,DESC_TXT,RTRN_TYP,VER_NBR,ACTV,
		TYP_ID,NMSPC_CD) 
	values (CONCAT('KCMIT', KRMS_FUNC_S.NEXTVAL),'allAwards','Include all awards','java.lang.Boolean',1,'Y',
		(select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-AWARD' and NM = 'Award Java Function Term Service'),'KC-AWARD')
/
insert into KRMS_FUNC_PARM_T (FUNC_PARM_ID,FUNC_ID,NM,DESC_TXT,TYP,SEQ_NO) 
	values (CONCAT('KCMIT', KRMS_FUNC_PARM_S.NEXTVAL),(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD'),
			'Award','Award BO','org.kuali.kra.award.home.Award',1)
/
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NMSPC_CD, NM, DESC_TXT, TYP, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL),'KC-AWARD',(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD'),
			'Include all awards','java.lang.Boolean','Y',1)
/
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL),(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-AWARD' and  
NM=(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD')),1,'Include all awards')
/
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
	values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL),'KC-AWARD-CONTEXT',(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-AWARD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD')),'Y')
/
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) 
	values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-AWARD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD')), 
			(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-AWARD' and NM='Function'))
/
insert into KRMS_TERM_RSLVR_T (TERM_RSLVR_ID, NMSPC_CD, NM, TYP_ID, OUTPUT_TERM_SPEC_ID, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_RSLVR_S.NEXTVAL),'KC-AWARD','All Award Resolver',
			(select TYP_ID from KRMS_TYP_T where NM='Function Term Resolver Type Service' and NMSPC_CD='KC-KRMS'),
			(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-AWARD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD')),'Y',1)
/
