update KRMS_FUNC_PARM_T set TYP='org.kuali.coeus.propdev.impl.core.DevelopmentProposal' where TYP='org.kuali.kra.proposaldevelopment.bo.DevelopmentProposal'
/
update KRMS_FUNC_T set TYP_ID = (select TYP_ID from KRMS_TYP_T where NMSPC_CD = 'KC-PD' and NM = 'MIT Custom Propdev Java Function Term Service') WHERE NM = 'coiAppointmentTypeRule'
/
