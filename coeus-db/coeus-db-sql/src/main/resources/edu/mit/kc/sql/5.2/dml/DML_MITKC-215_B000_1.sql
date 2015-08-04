--Script for deleting already existing entries with wrong sequence objects
Delete from KRMS_TERM_RSLVR_PARM_SPEC_T where NM='S2S Submission Type Code' and TERM_RSLVR_ID in(select TERM_RSLVR_ID 
from KRMS_TERM_RSLVR_T where NM='Check S2s Submission Type Resolver' and NMSPC_CD='KC-PD')
/
Delete from KRMS_TERM_RSLVR_T where NM='Check S2s Submission Type Resolver' and OUTPUT_TERM_SPEC_ID= (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2sSubmissionType' and NMSPC_CD='KC-PD'))
/
Delete from KRMS_TERM_SPEC_CTGRY_T where TERM_SPEC_ID = (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2sSubmissionType' and NMSPC_CD='KC-PD'))
/
Delete from KRMS_CNTXT_VLD_TERM_SPEC_T where TERM_SPEC_ID= (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2sSubmissionType' and NMSPC_CD='KC-PD'))
/
Delete from KRMS_TERM_SPEC_T where NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2sSubmissionType' and NMSPC_CD='KC-PD')
/
Delete from KRMS_FUNC_PARM_T where FUNC_ID = (select FUNC_ID from KRMS_FUNC_T where  NM='checkS2sSubmissionType' and NMSPC_CD='KC-PD') and
NM='S2s Submission Type Code'
/
Delete from KRMS_FUNC_PARM_T where FUNC_ID = (select FUNC_ID from KRMS_FUNC_T where  NM='checkS2sSubmissionType' and NMSPC_CD='KC-PD') and
NM='DevelopmentProposal'
/
Delete from KRMS_FUNC_T where NM='checkS2sSubmissionType'
/
--    public String checkS2SSubTypeRule(DevelopmentProposal developmentProposal,String S2sSubmissionTypeCode);
insert into KRMS_FUNC_T
	(FUNC_ID,NM,DESC_TXT,RTRN_TYP,VER_NBR,ACTV,TYP_ID,NMSPC_CD) 
	values (CONCAT('KCMIT', KRMS_FUNC_S.NEXTVAL),'checkS2SSubTypeRule','Check s2s submission type code rule','java.lang.String',1,'Y',
		(select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-PD' and NM = 'MIT Custom Propdev Java Function Term Service'),'KC-PD')
/
insert into KRMS_FUNC_PARM_T (FUNC_PARM_ID,FUNC_ID,NM,DESC_TXT,TYP,SEQ_NO) 
	values (CONCAT('KCMIT', KRMS_FUNC_PARM_S.NEXTVAL),(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2SSubTypeRule' and NMSPC_CD='KC-PD'),
			'DevelopmentProposal','Development Proposal BO','org.kuali.kra.proposaldevelopment.bo.DevelopmentProposal',1)
/
insert into KRMS_FUNC_PARM_T (FUNC_PARM_ID,FUNC_ID,NM,DESC_TXT,TYP,SEQ_NO) 
	values (CONCAT('KCMIT', KRMS_FUNC_PARM_S.NEXTVAL),(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2SSubTypeRule' and NMSPC_CD='KC-PD'),
			's2sSubTypeCode','s2sSubTypeCode','java.lang.String',2)
/
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NMSPC_CD, NM, DESC_TXT, TYP, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL),'KC-PD',(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2SSubTypeRule' and NMSPC_CD='KC-PD'),
			'Check S2S Sub Type Rule','java.lang.String','Y',1)
/
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
	values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL),'KC-PD-CONTEXT',(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2SSubTypeRule' and NMSPC_CD='KC-PD')),'Y')
/
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) 
	values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2SSubTypeRule' and NMSPC_CD='KC-PD')), 
			(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Function'))
/
insert into KRMS_TERM_RSLVR_T (TERM_RSLVR_ID, NMSPC_CD, NM, TYP_ID, OUTPUT_TERM_SPEC_ID, ACTV, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_RSLVR_S.NEXTVAL),'KC-PD','S2s Submission Type Code Check Resolver',
			(select TYP_ID from KRMS_TYP_T where NM='Function Term Resolver Type Service' and NMSPC_CD='KC-KRMS'),
			(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and 
					NM=(select FUNC_ID from KRMS_FUNC_T where  NM='checkS2SSubTypeRule' and NMSPC_CD='KC-PD')),'Y',1)
/
insert into KRMS_TERM_RSLVR_PARM_SPEC_T (TERM_RSLVR_PARM_SPEC_ID, TERM_RSLVR_ID, NM, VER_NBR) 
	values (CONCAT('KCMIT', KRMS_TERM_RSLVR_PARM_SPEC_S.NEXTVAL), (select TERM_RSLVR_ID from KRMS_TERM_RSLVR_T where NM='S2s Submission Type Code Check Resolver' and NMSPC_CD='KC-PD'), 
				's2sSubTypeCode', 1)
/
--end--