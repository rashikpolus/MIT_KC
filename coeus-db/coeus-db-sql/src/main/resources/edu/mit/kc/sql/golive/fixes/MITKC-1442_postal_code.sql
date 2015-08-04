UPDATE eps_prop_person
SET postal_code = postal_code||'0000'
WHERE COUNTRY_CODE = 'USA' 
AND length(postal_code) = 5
/
commit
/
