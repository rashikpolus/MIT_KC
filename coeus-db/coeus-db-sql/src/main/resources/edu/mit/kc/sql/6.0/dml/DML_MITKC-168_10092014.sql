DECLARE
	ls_value VARCHAR2(2000);
CURSOR c_cost_type IS
	SELECT s.SUBAWARD_ID,sc.VALUE FROM SUBAWARD s 
	INNER JOIN SUBAWARD_CUSTOM_DATA sc ON s.SUBAWARD_ID=sc.SUBAWARD_ID
	INNER JOIN CUSTOM_ATTRIBUTE c ON sc.CUSTOM_ATTRIBUTE_ID= c.ID
	WHERE c.NAME='SUB_CONTRACT_TYPE' AND sc.VALUE IS NOT NULL;
	r_cost_type c_cost_type%ROWTYPE;
BEGIN
	IF c_cost_type%ISOPEN THEN
	CLOSE c_cost_type;
	END IF;
	OPEN c_cost_type;
	LOOP
	FETCH c_cost_type INTO r_cost_type;
	EXIT WHEN c_cost_type%NOTFOUND;
	
			 UPDATE SUBAWARD
			 SET COST_TYPE = r_cost_type.VALUE
			 WHERE SUBAWARD_ID = r_cost_type.SUBAWARD_ID;
		   
	END LOOP;
	CLOSE c_cost_type;
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('Exception occured. The Error is '||sqlerrm);	
END;
/
commit
/
