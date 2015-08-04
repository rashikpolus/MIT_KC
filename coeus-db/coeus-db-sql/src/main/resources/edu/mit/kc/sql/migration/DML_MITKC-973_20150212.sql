insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL),(select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-AWARD' and  
NM=(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD')),1,'Include all awards')
/
update KRMS_FUNC_T set RTRN_TYP='java.lang.Boolean' where NM='allAwards' and NMSPC_CD='KC-AWARD'
/
update KRMS_TERM_SPEC_T set TYP='java.lang.Boolean' where NM=(select FUNC_ID from KRMS_FUNC_T where  NM='allAwards' and NMSPC_CD='KC-AWARD')
/
