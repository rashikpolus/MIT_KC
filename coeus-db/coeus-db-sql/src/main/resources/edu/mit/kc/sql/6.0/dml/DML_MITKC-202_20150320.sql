-- coiAppointmentTypeRule(DevelopmentProposal developmentProposal);    
insert into KRMS_FUNC_T (FUNC_ID,NM,DESC_TXT,RTRN_TYP,VER_NBR,ACTV,TYP_ID,NMSPC_CD) 
values (CONCAT('KC', KRMS_FUNC_S.NEXTVAL),'coiAppointmentTypeRule','CO-Is have PI status','java.lang.String',1,'Y',
(select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-PD' and NM = 'ProposalDevelopment Java Function Term Service'),'KC-PD')
/
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NMSPC_CD, NM, DESC_TXT, TYP, ACTV, VER_NBR) 
	values (CONCAT('KC', KRMS_TERM_SPEC_S.NEXTVAL),'KC-PD',(select FUNC_ID from KRMS_FUNC_T where  NM='coiAppointmentTypeRule' and NMSPC_CD='KC-PD'),
					'Check CO-Is have PI status','java.lang.Boolean','Y',1)
/
insert into KRMS_TERM_T(TERM_ID,TERM_SPEC_ID,VER_NBR,DESC_TXT) 
	values (CONCAT('KC', KRMS_TERM_S.NEXTVAL),(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='coiAppointmentTypeRule' and NMSPC_CD='KC-PD')),
			1,'Check CO-Is have PI status')
/
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
	values (CONCAT('KC', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL),'KC-PD-CONTEXT',
					(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='coiAppointmentTypeRule' and NMSPC_CD='KC-PD')),'Y')
/
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) 
	values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='coiAppointmentTypeRule' and NMSPC_CD='KC-PD')), 
			(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Function'))
/
insert into KRMS_TERM_RSLVR_T (TERM_RSLVR_ID, NMSPC_CD, NM, TYP_ID, OUTPUT_TERM_SPEC_ID, ACTV, VER_NBR) 
	values (CONCAT('KC', KRMS_TERM_RSLVR_S.NEXTVAL),'KC-PD','COI Status Resolver',
	(select TYP_ID from KRMS_TYP_T where NM='Function Term Resolver Type Service' and NMSPC_CD='KC-KRMS'),
			(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='coiAppointmentTypeRule' and NMSPC_CD='KC-PD')),'Y',1)
/
insert into KRMS_FUNC_PARM_T (FUNC_PARM_ID, NM, DESC_TXT, TYP, FUNC_ID, SEQ_NO)
	values (CONCAT('KC', KRMS_FUNC_PARM_S.NEXTVAL), 'DevelopmentProposal', 'Development Proposal', 'org.kuali.kra.proposaldevelopment.bo.DevelopmentProposal', 
	(select FUNC_ID from KRMS_FUNC_T where  NM='coiAppointmentTypeRule' and NMSPC_CD='KC-PD'), 1)
/
