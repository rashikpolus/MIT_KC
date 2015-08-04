-- piAppointmentTypeRule(DevelopmentProposal developmentProposal);    
update KRMS_FUNC_T set TYP_ID = (select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-PD' and NM = 'MIT Custom Propdev Java Function Term Service')--KCMIT1001
where NM = 'piAppointmentTypeRule' and DESC_TXT='PIs have PI status' and NMSPC_CD = 'KC-PD'
/
