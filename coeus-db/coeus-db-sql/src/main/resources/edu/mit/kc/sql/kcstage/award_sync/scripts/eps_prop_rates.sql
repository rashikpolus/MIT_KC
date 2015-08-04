select ' Started EPS_PROP_RATES, EPS_PROP_LA_RATES ' from dual
/
DECLARE
li_budget_id number(12);
CURSOR c_rates IS SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,t1.FISCAL_YEAR,t1.START_DATE,
t1.ON_OFF_CAMPUS_FLAG,t1.ACTIVITY_TYPE_CODE,t1.APPLICABLE_RATE,t1.INSTITUTE_RATE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER
 FROM OSP$EPS_PROP_RATES@coeus.kuali t1
 INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
 
r_rates c_rates%ROWTYPE;
 CURSOR c_la IS SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,t1.FISCAL_YEAR,t1.START_DATE,
 t1.ON_OFF_CAMPUS_FLAG,t1.APPLICABLE_RATE,t1.INSTITUTE_RATE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER
 FROM OSP$EPS_PROP_LA_RATES@coeus.kuali t1
 INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
 
r_la c_la%ROWTYPE;

BEGIN
		IF c_rates%ISOPEN THEN
		CLOSE c_rates;
		END IF;
		OPEN c_rates;
		LOOP
		FETCH c_rates INTO r_rates;
		EXIT WHEN c_rates%NOTFOUND;

	begin		
			select t1.budget_id  INTO li_budget_id  from budget t1 
			inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
			where t2.proposal_number = r_rates.PROPOSAL_NUMBER
			and t1.version_number = r_rates.VERSION_NUMBER;
			
	exception
	when no_data_found then
		null;
		continue;
	end;
		
			
/*		
			SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number = AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=r_rates.PROPOSAL_NUMBER)AND VER_NBR =r_rates.VERSION_NUMBER);
*/
			DELETE FROM EPS_PROP_RATES WHERE BUDGET_ID = li_budget_id;
		
	
		END LOOP;
		CLOSE c_rates;
		commit;
		IF c_la%ISOPEN THEN
		CLOSE c_la;
		END IF;
		OPEN c_la;
		LOOP
		FETCH c_la INTO r_la;
		EXIT WHEN c_la%NOTFOUND;

	begin		
			select t1.budget_id  INTO li_budget_id  from budget t1 
			inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
			where t2.proposal_number = r_la.PROPOSAL_NUMBER
			and t1.version_number = r_la.VERSION_NUMBER;	
	exception
	when no_data_found then
		null;
		continue;
	end;			
/*
			SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_la.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=r_la.PROPOSAL_NUMBER)AND VER_NBR =r_la.VERSION_NUMBER);
*/			
			
			DELETE FROM EPS_PROP_LA_RATES WHERE BUDGET_ID = li_budget_id;
			
		END LOOP;
		CLOSE c_la;

END;
/
commit
/
DECLARE

li_ver_nbr number(8):=1;
li_budget_id number(12);
li_prop_rates_count number;
li_prop_la_rates_count number;

CURSOR c_rates IS SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,t1.FISCAL_YEAR,t1.START_DATE,
t1.ON_OFF_CAMPUS_FLAG,t1.ACTIVITY_TYPE_CODE,t1.APPLICABLE_RATE,t1.INSTITUTE_RATE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER
 FROM OSP$EPS_PROP_RATES@coeus.kuali t1
 INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER; 
r_rates c_rates%ROWTYPE;

 CURSOR c_la IS 
 SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,t1.FISCAL_YEAR,t1.START_DATE,
 t1.ON_OFF_CAMPUS_FLAG,t1.APPLICABLE_RATE,t1.INSTITUTE_RATE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER
 FROM OSP$EPS_PROP_LA_RATES@coeus.kuali t1
 INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
 
r_la c_la%ROWTYPE;

BEGIN
IF c_rates%ISOPEN THEN
CLOSE c_rates;
END IF;
OPEN c_rates;
LOOP
FETCH c_rates INTO r_rates;
EXIT WHEN c_rates%NOTFOUND;

	begin
		
			select t1.budget_id  INTO li_budget_id  from budget t1 
			inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
			where t2.proposal_number = r_rates.PROPOSAL_NUMBER
			and t1.version_number = r_rates.VERSION_NUMBER;	
		
	exception
	when no_data_found then
		null;
		continue;
	end;

		
	BEGIN

	INSERT INTO EPS_PROP_RATES(BUDGET_ID,RATE_CLASS_CODE,RATE_TYPE_CODE,FISCAL_YEAR,ON_OFF_CAMPUS_FLAG,START_DATE,ACTIVITY_TYPE_CODE,APPLICABLE_RATE,INSTITUTE_RATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	VALUES(li_budget_id,r_rates.RATE_CLASS_CODE,r_rates.RATE_TYPE_CODE,r_rates.FISCAL_YEAR,r_rates.ON_OFF_CAMPUS_FLAG,r_rates.START_DATE,r_rates.ACTIVITY_TYPE_CODE,decode(r_rates.APPLICABLE_RATE,-1,0,r_rates.APPLICABLE_RATE),r_rates.INSTITUTE_RATE,r_rates.UPDATE_TIMESTAMP,r_rates.UPDATE_USER,li_ver_nbr,SYS_GUID());

	EXCEPTION
		WHEN OTHERS THEN
		dbms_output.put_line('EPS_PROP_RATES '||substr(sqlerrm,1,200));
	END;

END LOOP;
CLOSE c_rates;

IF c_la%ISOPEN THEN
CLOSE c_la;
END IF;
OPEN c_la;
LOOP
FETCH c_la INTO r_la;
EXIT WHEN c_la%NOTFOUND;

	begin
	
			select t1.budget_id  INTO li_budget_id  from budget t1 
			inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
			where t2.proposal_number = r_la.PROPOSAL_NUMBER
			and t1.version_number = r_la.VERSION_NUMBER;	
		
		
	exception
	when no_data_found then
		null;
		continue;
	end;

	BEGIN

	INSERT INTO EPS_PROP_LA_RATES(BUDGET_ID,RATE_TYPE_CODE,FISCAL_YEAR,ON_OFF_CAMPUS_FLAG,START_DATE,RATE_CLASS_CODE,APPLICABLE_RATE,INSTITUTE_RATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	VALUES(li_budget_id,r_la.RATE_TYPE_CODE,r_la.FISCAL_YEAR,r_la.ON_OFF_CAMPUS_FLAG,r_la.START_DATE,r_la.RATE_CLASS_CODE,decode(r_la.APPLICABLE_RATE,-1,0,r_la.APPLICABLE_RATE),r_la.INSTITUTE_RATE,r_la.UPDATE_TIMESTAMP,r_la.UPDATE_USER,li_ver_nbr,SYS_GUID());

	EXCEPTION
		WHEN OTHERS THEN
		dbms_output.put_line('EPS_PROP_LA_RATES '||substr(sqlerrm,1,200));
	END;

END LOOP;
CLOSE c_la;
END;
/
select ' Ended EPS_PROP_RATES, EPS_PROP_LA_RATES ' from dual
/