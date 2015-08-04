UPDATE KRMS_FUNC_PARM_T SET NM = 'Fellowship Codes' WHERE NM = 'fellowship codes' and FUNC_ID=(select FUNC_ID from KRMS_FUNC_T where  NM='divisionCodeIsFellowship' and NMSPC_CD='KC-PD')
/
