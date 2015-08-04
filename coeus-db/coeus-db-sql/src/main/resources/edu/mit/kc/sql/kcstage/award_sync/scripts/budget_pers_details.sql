select ' Started BUDGET_PERSONNEL_DETAILS,BUDGET_PERSONNEL_CAL_AMTS,BUDGET_PER_DET_RATE_AND_BASE ' from dual
/
DECLARE
li_ver_nbr number(8):=1;
li_budget_period_number number(12);
li_budget_id number(12);
li_bud_period number(12);
li_budget_details_id number(12);
ls_group_name varchar2(25):=null;
ls_hierarchy_prop_num varchar2(12);
ls_hide_in_hierarchy char(1):='N';
li_budget_per_det_id number(12);
li_person_sequence_number number(3):=null;
li_seq_bud_per_cal number(12);
li_seq_bud_per_rate_base  number(12);
ls_rate_type_desc varchar2(200):=null;
li_bud_det_cal_id number(12);
li_loop_count number;
li_error_count number;
flag_budgte_id number:=0;
flag_next number:=0;
li_fk_det_id number(12);
li_fk_det_cal_id number(12);
li_count_bud_per_det number;
li_count_bud_per_det_cal number;
li_count_bud_per_rate_base number;
li_sequence_number	NUMBER(3,0);
li_rolodex_id VARCHAR2(9);  
li_person_id VARCHAR2(40);
ls_person VARCHAR2(40);
li_rolodex_count number;
ls_proposal_number VARCHAR2(12);
ls_prop_num VARCHAR2(12);
li_count NUMBER;

CURSOR c_personnel IS 
SELECT t1.PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.BUDGET_PERIOD,t1.LINE_ITEM_NUMBER,t1.PERSON_NUMBER,t1.PERSON_ID,t1.JOB_CODE,t1.START_DATE,t1.END_DATE,t1.PERIOD_TYPE,
t1.LINE_ITEM_DESCRIPTION,t1.SEQUENCE_NUMBER,t1.SALARY_REQUESTED,t1.PERCENT_CHARGED,t1.PERCENT_EFFORT,t1.COST_SHARING_PERCENT,t1.COST_SHARING_AMOUNT,
t1.UNDERRECOVERY_AMOUNT,t1.ON_OFF_CAMPUS_FLAG,t1.APPLY_IN_RATE_FLAG,t1.BUDGET_JUSTIFICATION,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER 
FROM OSP$BUDGET_PERSONNEL_DETAILS@coeus.kuali t1
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_personnel c_personnel%ROWTYPE;

CURSOR c_per_cal(pn varchar2,ver number,bp number,li number,per_num number) IS 
SELECT to_number(PROPOSAL_NUMBER) PROPOSAL_NUMBER,VERSION_NUMBER,BUDGET_PERIOD,LINE_ITEM_NUMBER,PERSON_NUMBER,RATE_CLASS_CODE,RATE_TYPE_CODE,APPLY_RATE_FLAG,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER 
FROM OSP$BUDGET_PERSONNEL_CAL_AMTS@coeus.kuali WHERE PROPOSAL_NUMBER= pn AND VERSION_NUMBER=ver AND BUDGET_PERIOD=bp AND LINE_ITEM_NUMBER=li AND PERSON_NUMBER=per_num;
r_per_cal c_per_cal%ROWTYPE;

CURSOR c_per_rate_base IS 
SELECT t1.PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.BUDGET_PERIOD,t1.LINE_ITEM_NUMBER,t1.PERSON_NUMBER,t1.RATE_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,
t1.PERSON_ID,t1.START_DATE,t1.END_DATE,t1.ON_OFF_CAMPUS_FLAG,t1.APPLIED_RATE,t1.SALARY_REQUESTED,t1.BASE_COST_SHARING,t1.CALCULATED_COST,
t1.CALCULATED_COST_SHARING,t1.JOB_CODE,t1.BASE_COST,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER 
FROM OSP$BUD_PER_DET_RATE_AND_BASE@coeus.kuali t1 
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_per_rate_base c_per_rate_base%ROWTYPE;



BEGIN

IF c_personnel%ISOPEN THEN
CLOSE c_personnel;
END IF;
OPEN c_personnel;
li_error_count:=0;
li_loop_count:=0;
LOOP
FETCH c_personnel INTO r_personnel;
EXIT WHEN c_personnel%NOTFOUND;
select to_number(r_personnel.PROPOSAL_NUMBER) into ls_proposal_number from dual;

BEGIN

SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_personnel.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number)AND VER_NBR =r_personnel.VERSION_NUMBER);

SELECT BUDGET_PERIOD_NUMBER INTO li_bud_period FROM BUDGET_PERIODS WHERE BUDGET_ID=li_budget_id and budget_period=r_personnel.BUDGET_PERIOD;
SELECT BUDGET_DETAILS_ID INTO li_budget_details_id FROM BUDGET_DETAILS WHERE BUDGET_ID=li_budget_id  AND BUDGET_PERIOD=r_personnel.BUDGET_PERIOD AND LINE_ITEM_NUMBER=r_personnel.LINE_ITEM_NUMBER;
SELECT SEQ_BUDGET_PER_DET_ID.NEXTVAL INTO li_budget_per_det_id FROM DUAL;

 begin
    select count(rolodex_id) into li_rolodex_count from ROLODEX where rolodex_id=r_personnel.PERSON_ID;
     if li_rolodex_count>0 then
     li_rolodex_id:=r_personnel.PERSON_ID;
     li_person_id:=null;
     else
     select  fn_get_prncpl_id(r_personnel.PERSON_ID) into li_person_id from dual;
     if li_person_id='-1' then
        li_person_id:=r_personnel.PERSON_ID;
     end if;        
     li_rolodex_id:=null;
     end if; 
   exception
   when others then    
     select  fn_get_prncpl_id(r_personnel.PERSON_ID) into li_person_id from dual;
     if li_person_id='-1' then
        li_person_id:=r_personnel.PERSON_ID;
     end if;        
     li_rolodex_id:=null; 
  end;
     
BEGIN
SELECT PERSON_SEQUENCE_NUMBER INTO li_person_sequence_number FROM BUDGET_PERSONS WHERE BUDGET_ID=li_budget_id AND (ROLODEX_ID=li_rolodex_id OR PERSON_ID=li_person_id) AND JOB_CODE=r_personnel.JOB_CODE;
EXCEPTION
WHEN TOO_MANY_ROWS THEN

if flag_budgte_id=li_budget_id then   
   flag_next:=flag_next+1;
   li_person_sequence_number:=flag_next;   
else
flag_budgte_id:=0;
end if;

if flag_budgte_id=0 then
   SELECT MIN(PERSON_SEQUENCE_NUMBER) INTO flag_next FROM BUDGET_PERSONS WHERE BUDGET_ID=li_budget_id AND (ROLODEX_ID=li_rolodex_id OR PERSON_ID=li_person_id) AND JOB_CODE=r_personnel.JOB_CODE;
   li_person_sequence_number:=flag_next;    
end if;
flag_budgte_id:=li_budget_id;  
END;

if  r_personnel.SEQUENCE_NUMBER=-1 then
    li_sequence_number:=null;
else
    li_sequence_number:=r_personnel.SEQUENCE_NUMBER;
end if;

    select  fn_get_prncpl_id(r_personnel.PERSON_ID) into ls_person from dual;
     if ls_person='-1' then
        ls_person:=r_personnel.PERSON_ID;
     end if;        

		 SELECT count(budget_personnel_details_id) into li_count FROM BUDGET_PERSONNEL_DETAILS
		 WHERE BUDGET_ID = li_budget_id
		 AND   BUDGET_PERIOD = r_personnel.BUDGET_PERIOD
		 AND   LINE_ITEM_NUMBER = r_personnel.LINE_ITEM_NUMBER
		 AND   PERSON_NUMBER = r_personnel.PERSON_NUMBER;
	 
		if li_count = 0 then -- INSERT
			INSERT INTO BUDGET_PERSONNEL_DETAILS(BUDGET_PERSONNEL_DETAILS_ID,PERSON_SEQUENCE_NUMBER,BUDGET_PERIOD_NUMBER,BUDGET_ID,LINE_ITEM_NUMBER,PERSON_NUMBER,PERSON_ID,JOB_CODE,START_DATE,END_DATE,PERIOD_TYPE,LINE_ITEM_DESCRIPTION,SEQUENCE_NUMBER,SALARY_REQUESTED,PERCENT_CHARGED,PERCENT_EFFORT,COST_SHARING_PERCENT,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,ON_OFF_CAMPUS_FLAG,APPLY_IN_RATE_FLAG,BUDGET_JUSTIFICATION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_PERIOD,BUDGET_DETAILS_ID,OBJ_ID)
			VALUES(li_budget_per_det_id,li_person_sequence_number,li_bud_period,li_budget_id,r_personnel.LINE_ITEM_NUMBER,r_personnel.PERSON_NUMBER,ls_person,r_personnel.JOB_CODE,r_personnel.START_DATE,r_personnel.END_DATE,DECODE(r_personnel.PERIOD_TYPE,'AP','2','CY','3','SP','4',r_personnel.PERIOD_TYPE),r_personnel.LINE_ITEM_DESCRIPTION,li_sequence_number,r_personnel.SALARY_REQUESTED,r_personnel.PERCENT_CHARGED,r_personnel.PERCENT_EFFORT,r_personnel.COST_SHARING_PERCENT,r_personnel.COST_SHARING_AMOUNT,r_personnel.UNDERRECOVERY_AMOUNT,r_personnel.ON_OFF_CAMPUS_FLAG,r_personnel.APPLY_IN_RATE_FLAG,r_personnel.BUDGET_JUSTIFICATION,r_personnel.UPDATE_TIMESTAMP,r_personnel.UPDATE_USER,li_ver_nbr,r_personnel.BUDGET_PERIOD,li_budget_details_id,SYS_GUID());

		else
			UPDATE BUDGET_PERSONNEL_DETAILS SET
				JOB_CODE = r_personnel.JOB_CODE,
				START_DATE = r_personnel.START_DATE,
				END_DATE = r_personnel.END_DATE,
				PERIOD_TYPE = DECODE(r_personnel.PERIOD_TYPE,'AP','2','CY','3','SP','4',r_personnel.PERIOD_TYPE),
				LINE_ITEM_DESCRIPTION = r_personnel.LINE_ITEM_DESCRIPTION,
				SALARY_REQUESTED = r_personnel.SALARY_REQUESTED,
				PERCENT_CHARGED = r_personnel.PERCENT_CHARGED,
				PERCENT_EFFORT = r_personnel.PERCENT_EFFORT,
				COST_SHARING_PERCENT = r_personnel.COST_SHARING_PERCENT,
				COST_SHARING_AMOUNT = r_personnel.COST_SHARING_AMOUNT,
				UNDERRECOVERY_AMOUNT = r_personnel.UNDERRECOVERY_AMOUNT,
				ON_OFF_CAMPUS_FLAG = r_personnel.ON_OFF_CAMPUS_FLAG,
				APPLY_IN_RATE_FLAG = r_personnel.APPLY_IN_RATE_FLAG,
				BUDGET_JUSTIFICATION = r_personnel.BUDGET_JUSTIFICATION,
				UPDATE_TIMESTAMP = r_personnel.UPDATE_TIMESTAMP,
				UPDATE_USER = r_personnel.UPDATE_USER
			 WHERE BUDGET_ID = li_budget_id
			 AND   BUDGET_PERIOD = r_personnel.BUDGET_PERIOD
			 AND   LINE_ITEM_NUMBER = r_personnel.LINE_ITEM_NUMBER
			 AND   PERSON_NUMBER = r_personnel.PERSON_NUMBER;
		
		end if;
	 
                IF c_per_cal%isopen then
                CLOSE c_per_cal;
                END IF;
                OPEN c_per_cal(r_personnel.PROPOSAL_NUMBER,r_personnel.VERSION_NUMBER,r_personnel.BUDGET_PERIOD,r_personnel.LINE_ITEM_NUMBER,r_personnel.PERSON_NUMBER);
                LOOP
                FETCH c_per_cal INTO r_per_cal;
                EXIT WHEN c_per_cal%NOTFOUND;             
                
                SELECT SEQ_BUDGET_PER_CAL_AMTS_ID.NEXTVAL INTO li_seq_bud_per_cal FROM DUAL;
                
                BEGIN 
				
					SELECT COUNT(budget_personnel_cal_amts_id) INTO li_count FROM BUDGET_PERSONNEL_CAL_AMTS
					WHERE BUDGET_ID = li_budget_id
					AND	BUDGET_PERIOD = r_per_cal.BUDGET_PERIOD
					AND	LINE_ITEM_NUMBER = r_per_cal.LINE_ITEM_NUMBER
					AND	PERSON_NUMBER = r_per_cal.PERSON_NUMBER
					AND	RATE_CLASS_CODE = r_per_cal.RATE_CLASS_CODE
					AND	RATE_TYPE_CODE = r_per_cal.RATE_TYPE_CODE;
				
					if li_count = 0 then -- INSERT
				
						INSERT INTO BUDGET_PERSONNEL_CAL_AMTS(BUDGET_PERSONNEL_CAL_AMTS_ID,BUDGET_PERIOD_NUMBER,BUDGET_ID,BUDGET_PERIOD,LINE_ITEM_NUMBER,PERSON_NUMBER,RATE_CLASS_CODE,RATE_TYPE_CODE,APPLY_RATE_FLAG,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_PERSONNEL_DETAILS_ID,OBJ_ID,RATE_TYPE_DESCRIPTION)
						VALUES(li_seq_bud_per_cal,li_bud_period,li_budget_id,r_per_cal.BUDGET_PERIOD,r_per_cal.LINE_ITEM_NUMBER,r_per_cal.PERSON_NUMBER,r_per_cal.RATE_CLASS_CODE,r_per_cal.RATE_TYPE_CODE,r_per_cal.APPLY_RATE_FLAG,r_per_cal.CALCULATED_COST,r_per_cal.CALCULATED_COST_SHARING,r_per_cal.UPDATE_TIMESTAMP,r_per_cal.UPDATE_USER,li_ver_nbr,li_budget_per_det_id,SYS_GUID(),ls_rate_type_desc);
					
					else -- UPDATE
						UPDATE BUDGET_PERSONNEL_CAL_AMTS SET 
							APPLY_RATE_FLAG = r_per_cal.APPLY_RATE_FLAG,
							CALCULATED_COST = r_per_cal.CALCULATED_COST,
							CALCULATED_COST_SHARING = r_per_cal.CALCULATED_COST_SHARING,
							UPDATE_TIMESTAMP = r_per_cal.UPDATE_TIMESTAMP,
							UPDATE_USER = r_per_cal.UPDATE_USER
						WHERE BUDGET_ID = li_budget_id
						AND	BUDGET_PERIOD = r_per_cal.BUDGET_PERIOD
						AND	LINE_ITEM_NUMBER = r_per_cal.LINE_ITEM_NUMBER
						AND	PERSON_NUMBER = r_per_cal.PERSON_NUMBER
						AND	RATE_CLASS_CODE = r_per_cal.RATE_CLASS_CODE
						AND	RATE_TYPE_CODE = r_per_cal.RATE_TYPE_CODE;
					
					end if;	
				
				
				EXCEPTION 
                WHEN OTHERS THEN                   
                    dbms_output.put_line('Error in BUDGET_PERSONNEL_CAL_AMTS  Proposal Number is '||ls_proposal_number||' ,Version Number is '||r_personnel.VERSION_NUMBER||' and Budget Period is '||r_personnel.BUDGET_PERIOD||' .'||substr(sqlerrm,1,200));
                END;
                  END LOOP;
                CLOSE c_per_cal; 

                  EXCEPTION 
                   WHEN OTHERS THEN                   
                   dbms_output.put_line('Missing data in BUDGET or BUDGET_PERIODS or BUDGET_DETAILS , while inserting into BUDGET_PERSONNEL_DETAILS Proposal Number is '||ls_proposal_number||' ,Version Number is '||r_personnel.VERSION_NUMBER||' and Budget Period is '||r_personnel.BUDGET_PERIOD||' .'||substr(sqlerrm,1,200));
                   li_error_count:=li_error_count+1;
                    END;
                   li_loop_count:=li_loop_count+1;
                    END LOOP;
                   CLOSE c_personnel;             


                IF c_per_rate_base%isopen then
                CLOSE c_per_rate_base;
                END IF;
                OPEN c_per_rate_base;
                LOOP
                FETCH c_per_rate_base INTO r_per_rate_base;
                EXIT WHEN c_per_rate_base%NOTFOUND;               
                select to_number(r_per_rate_base.PROPOSAL_NUMBER) into ls_prop_num from dual;
                SELECT SEQ_BGT_PER_DET_RATE_BASE_ID.NEXTVAL INTO li_seq_bud_per_rate_base FROM DUAL;
				
                BEGIN            
					SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_per_rate_base.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_prop_num)AND VER_NBR =r_per_rate_base.VERSION_NUMBER);
					SELECT BUDGET_PERIOD_NUMBER INTO li_bud_period FROM BUDGET_PERIODS WHERE BUDGET_ID=li_budget_id and budget_period=r_per_rate_base.BUDGET_PERIOD;
					
					begin
						SELECT BUDGET_PERSONNEL_DETAILS_ID,BUDGET_PERSONNEL_CAL_AMTS_ID into li_fk_det_id,li_fk_det_cal_id FROM BUDGET_PERSONNEL_CAL_AMTS WHERE BUDGET_ID=li_budget_id AND BUDGET_PERIOD=r_per_rate_base.BUDGET_PERIOD AND LINE_ITEM_NUMBER=r_per_rate_base.LINE_ITEM_NUMBER AND PERSON_NUMBER=r_per_rate_base.PERSON_NUMBER AND RATE_CLASS_CODE=r_per_rate_base.RATE_CLASS_CODE AND RATE_TYPE_CODE=r_per_rate_base.RATE_TYPE_CODE;               
					exception
						 when no_data_found then
						 li_fk_det_id:=null;
						 li_fk_det_cal_id:=null;
					end;
				
					select  fn_get_prncpl_id(r_per_rate_base.PERSON_ID) into ls_person from dual;
				   if ls_person='-1' then
					  ls_person:=r_per_rate_base.PERSON_ID;
				   end if;  
			   
					SELECT COUNT(bgt_per_det_rate_and_base_id) INTO  li_count 
					FROM BUDGET_PER_DET_RATE_AND_BASE
					WHERE BUDGET_ID = li_budget_id
					AND   BUDGET_PERIOD = r_per_rate_base.BUDGET_PERIOD
					AND  LINE_ITEM_NUMBER = r_per_rate_base.LINE_ITEM_NUMBER
					AND PERSON_NUMBER = r_per_rate_base.PERSON_NUMBER
					AND RATE_NUMBER = r_per_rate_base.RATE_NUMBER
					AND RATE_CLASS_CODE = r_per_rate_base.RATE_CLASS_CODE
					AND RATE_TYPE_CODE = r_per_rate_base.RATE_TYPE_CODE;
								   
				if li_count = 0 then
					INSERT INTO BUDGET_PER_DET_RATE_AND_BASE(BGT_PER_DET_RATE_AND_BASE_ID,BUDGET_ID,BUDGET_PERIOD,LINE_ITEM_NUMBER,PERSON_NUMBER,RATE_NUMBER,PERSON_ID,START_DATE,END_DATE,RATE_CLASS_CODE,RATE_TYPE_CODE,ON_OFF_CAMPUS_FLAG,APPLIED_RATE,SALARY_REQUESTED,BASE_COST_SHARING,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,UNDERRECOVERY_AMOUNT,BUDGET_PERIOD_NUMBER,BUDGET_PERSONNEL_DETAILS_ID,BUDGET_PERSONNEL_CAL_AMTS_ID,OBJ_ID)
					VALUES(li_seq_bud_per_rate_base,li_budget_id,r_per_rate_base.BUDGET_PERIOD,r_per_rate_base.LINE_ITEM_NUMBER,r_per_rate_base.PERSON_NUMBER,r_per_rate_base.RATE_NUMBER,ls_person,r_per_rate_base.START_DATE,r_per_rate_base.END_DATE,r_per_rate_base.RATE_CLASS_CODE,r_per_rate_base.RATE_TYPE_CODE,r_per_rate_base.ON_OFF_CAMPUS_FLAG,r_per_rate_base.APPLIED_RATE,r_per_rate_base.SALARY_REQUESTED,r_per_rate_base.BASE_COST_SHARING,r_per_rate_base.CALCULATED_COST,r_per_rate_base.CALCULATED_COST_SHARING,r_per_rate_base.UPDATE_TIMESTAMP,r_per_rate_base.UPDATE_USER,li_ver_nbr,null,li_bud_period,li_fk_det_id,li_fk_det_cal_id,SYS_GUID());
                
				else
					UPDATE BUDGET_PER_DET_RATE_AND_BASE SET 
					START_DATE = r_per_rate_base.START_DATE,
					END_DATE = r_per_rate_base.END_DATE,
					ON_OFF_CAMPUS_FLAG = r_per_rate_base.ON_OFF_CAMPUS_FLAG,
					APPLIED_RATE = r_per_rate_base.APPLIED_RATE,
					SALARY_REQUESTED = r_per_rate_base.SALARY_REQUESTED,
					BASE_COST_SHARING = r_per_rate_base.BASE_COST_SHARING,
					CALCULATED_COST = r_per_rate_base.CALCULATED_COST,
					CALCULATED_COST_SHARING = r_per_rate_base.CALCULATED_COST_SHARING,
					UPDATE_TIMESTAMP = r_per_rate_base.UPDATE_TIMESTAMP,
					UPDATE_USER = r_per_rate_base.UPDATE_USER
					WHERE BUDGET_ID = li_budget_id
					AND   BUDGET_PERIOD = r_per_rate_base.BUDGET_PERIOD
					AND  LINE_ITEM_NUMBER = r_per_rate_base.LINE_ITEM_NUMBER
					AND PERSON_NUMBER = r_per_rate_base.PERSON_NUMBER
					AND RATE_NUMBER = r_per_rate_base.RATE_NUMBER
					AND RATE_CLASS_CODE = r_per_rate_base.RATE_CLASS_CODE
					AND RATE_TYPE_CODE = r_per_rate_base.RATE_TYPE_CODE;
				
				end if;
			   
			   

				EXCEPTION
                     WHEN OTHERS THEN                   
                    dbms_output.put_line('Error in BUDGET_PER_DET_RATE_AND_BASE  Proposal Number is '||ls_prop_num||' ,Version Number is '||r_per_rate_base.VERSION_NUMBER||' and Budget Period is '||r_per_rate_base.BUDGET_PERIOD||' .'||substr(sqlerrm,1,200));
                END;
                
                END LOOP;
                CLOSE c_per_rate_base;  
                END;                      
 
/
select ' Ended BUDGET_PERSONNEL_DETAILS,BUDGET_PERSONNEL_CAL_AMTS,BUDGET_PER_DET_RATE_AND_BASE ' from dual
/