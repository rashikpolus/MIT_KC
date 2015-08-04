delete from KREW_TYP_ATTR_T where TYP_ID in ( select TYP_ID from KREW_TYP_T where NM = 'Sample Type' )
/
delete from KREW_TYP_T where NM = 'Sample Type'
/
commit
/

