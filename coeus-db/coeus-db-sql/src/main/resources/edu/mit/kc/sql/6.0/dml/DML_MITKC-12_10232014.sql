DECLARE
ls_char_eff_date VARCHAR2(20);
ll_eff_date DATE;
CURSOR c_stipend IS
SELECT training_stipend_rates_id,effective_date FROM training_stipend_rates;
r_stipend c_stipend%ROWTYPE;

BEGIN
IF c_stipend%ISOPEN THEN
CLOSE c_stipend;
END IF;
OPEN c_stipend;
LOOP
FETCH c_stipend INTO r_stipend;
EXIT WHEN c_stipend%NOTFOUND;

SELECT to_char(to_date(effective_date,'DD/MM/RRRR'),'DD/MM/RRRR') INTO ls_char_eff_date 
from training_stipend_rates
WHERE training_stipend_rates_id = r_stipend.training_stipend_rates_id;

SELECT TO_DATE(ls_char_eff_date,'DD/MM/YYYY') INTO ll_eff_date FROM DUAL;

UPDATE training_stipend_rates
SET effective_date = ll_eff_date
WHERE training_stipend_rates_id = r_stipend.training_stipend_rates_id;

END LOOP;
CLOSE c_stipend;
END;
/
commit
/
