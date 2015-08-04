UPDATE KRIM_ENTITY_ADDR_T SET POSTAL_CD = '021394307' WHERE POSTAL_CD = '02139'
/
commit
/
UPDATE rolodex SET postal_code = postal_code||'0000'
WHERE rolodex_id in (  SELECT rolodex_id FROM rolodex WHERE country_code = 'USA' AND LENGTH(trim(postal_code)) = 5 )
/
commit
/
