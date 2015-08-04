select ' Started BUDGET_DETAILS,BUDGET_DETAILS_CAL_AMTS,BUDGET_RATE_AND_BASE ' from dual
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
li_seq_bud_per_cal number(12);
ls_rate_type_desc varchar2(200):=null;
li_bud_det_cal_id number(12);
li_fk_det_cal_id number(12);
li_bud_rate_base_id number(12);
li_fk_bud_details_id number(12);
         li_count_budget_detail number;
         li_count_bud_cal_amt number;
         li_count_bud_rate_base number;
ls_proposal_number  varchar2(12);
ls_prop_num varchar2(12);

li_count number;

CURSOR c_details IS
	SELECT t1.PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.BUDGET_PERIOD,t1.LINE_ITEM_NUMBER,t1.BUDGET_CATEGORY_CODE,t1.COST_ELEMENT,
	t1.LINE_ITEM_DESCRIPTION,t1.BASED_ON_LINE_ITEM,t1.LINE_ITEM_SEQUENCE,t1.START_DATE,t1.END_DATE,t1.LINE_ITEM_COST,t1.COST_SHARING_AMOUNT,
	t1.UNDERRECOVERY_AMOUNT,t1.ON_OFF_CAMPUS_FLAG,t1.APPLY_IN_RATE_FLAG,t1.BUDGET_JUSTIFICATION,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.QUANTITY,
	t1.SUBMIT_COST_SHARING_FLAG as SUBMIT_COST_SHARING,to_number(t1.SUB_AWARD_NUMBER) as SUBAWARD_NUMBER
	FROM OSP$BUDGET_DETAILS@coeus.kuali t1
	INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_details c_details%ROWTYPE;

CURSOR c_cal_amt(pn varchar2,ver number,bp number,li number) IS 
	SELECT to_number(PROPOSAL_NUMBER) PROPOSAL_NUMBER,VERSION_NUMBER,BUDGET_PERIOD,LINE_ITEM_NUMBER,RATE_CLASS_CODE,RATE_TYPE_CODE,APPLY_RATE_FLAG,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER 
	FROM OSP$BUDGET_DETAILS_CAL_AMTS@coeus.kuali where PROPOSAL_NUMBER=pn and VERSION_NUMBER=ver and BUDGET_PERIOD=bp and LINE_ITEM_NUMBER=li;
r_cal_amt c_cal_amt%ROWTYPE;

CURSOR c_rate_base IS
	SELECT t1.PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.BUDGET_PERIOD,t1.LINE_ITEM_NUMBER,t1.RATE_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,t1.START_DATE,t1.END_DATE,
	t1.ON_OFF_CAMPUS_FLAG,t1.APPLIED_RATE,t1.BASE_COST,t1.BASE_COST_SHARING,t1.CALCULATED_COST,t1.CALCULATED_COST_SHARING,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER
	FROM OSP$BUDGET_RATE_AND_BASE@coeus.kuali t1
	INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_rate_base c_rate_base%ROWTYPE;

BEGIN

IF c_details%ISOPEN THEN
CLOSE c_details;
END IF;

OPEN c_details;
LOOP
FETCH c_details INTO r_details;
EXIT WHEN c_details%NOTFOUND;
SELECT SEQ_BUDGET_DETAILS_ID.NEXTVAL INTO li_budget_details_id FROM DUAL;
select to_number(r_details.PROPOSAL_NUMBER) into ls_proposal_number from dual;

 BEGIN
 
    SELECT  HIERARCHY_PROPOSAL_NUMBER INTO ls_hierarchy_prop_num FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER = ls_proposal_number;

    EXCEPTION
    WHEN OTHERS THEN
    ls_hierarchy_prop_num:=NULL;
    END;

	BEGIN
		SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_details.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number)AND VER_NBR =r_details.VERSION_NUMBER);
		SELECT BUDGET_PERIOD_NUMBER INTO li_bud_period FROM BUDGET_PERIODS WHERE BUDGET_ID=li_budget_id and budget_period=r_details.BUDGET_PERIOD;

		select count(budget_details_id) into li_count from BUDGET_DETAILS 
		WHERE BUDGET_ID = li_budget_id 
		and BUDGET_PERIOD_NUMBER = li_bud_period 
		and LINE_ITEM_NUMBER = r_details.LINE_ITEM_NUMBER;
		
		if li_count = 0 then -- INSERT
			INSERT INTO BUDGET_DETAILS(BUDGET_DETAILS_ID,BUDGET_PERIOD_NUMBER,GROUP_NAME,BUDGET_ID,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,BUDGET_PERIOD,LINE_ITEM_NUMBER,BUDGET_CATEGORY_CODE,COST_ELEMENT,LINE_ITEM_DESCRIPTION,BASED_ON_LINE_ITEM,LINE_ITEM_SEQUENCE,START_DATE,END_DATE,LINE_ITEM_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,ON_OFF_CAMPUS_FLAG,APPLY_IN_RATE_FLAG,BUDGET_JUSTIFICATION,UPDATE_TIMESTAMP,UPDATE_USER,QUANTITY,VER_NBR,OBJ_ID,SUBMIT_COST_SHARING,SUBAWARD_NUMBER)
			VALUES(li_budget_details_id,li_bud_period,ls_group_name,li_budget_id,ls_hierarchy_prop_num,ls_hide_in_hierarchy,r_details.BUDGET_PERIOD,r_details.LINE_ITEM_NUMBER,r_details.BUDGET_CATEGORY_CODE,r_details.COST_ELEMENT,r_details.LINE_ITEM_DESCRIPTION,r_details.BASED_ON_LINE_ITEM,r_details.LINE_ITEM_SEQUENCE,r_details.START_DATE,r_details.END_DATE,r_details.LINE_ITEM_COST,r_details.COST_SHARING_AMOUNT,r_details.UNDERRECOVERY_AMOUNT,r_details.ON_OFF_CAMPUS_FLAG,r_details.APPLY_IN_RATE_FLAG,
			r_details.BUDGET_JUSTIFICATION,r_details.UPDATE_TIMESTAMP,r_details.UPDATE_USER,r_details.QUANTITY,li_ver_nbr,SYS_GUID(),r_details.SUBMIT_COST_SHARING,r_details.SUBAWARD_NUMBER);

		else -- UPDATE
			 update BUDGET_DETAILS SET	
				COST_ELEMENT = r_details.COST_ELEMENT,
				LINE_ITEM_DESCRIPTION = r_details.LINE_ITEM_DESCRIPTION,
				START_DATE = r_details.START_DATE,
				END_DATE = r_details.END_DATE,
				LINE_ITEM_COST = r_details.LINE_ITEM_COST,
				COST_SHARING_AMOUNT = r_details.COST_SHARING_AMOUNT,
				UNDERRECOVERY_AMOUNT = r_details.UNDERRECOVERY_AMOUNT,
				ON_OFF_CAMPUS_FLAG = r_details.ON_OFF_CAMPUS_FLAG,
				APPLY_IN_RATE_FLAG = r_details.APPLY_IN_RATE_FLAG,
				BUDGET_JUSTIFICATION = r_details.BUDGET_JUSTIFICATION,
				UPDATE_TIMESTAMP = r_details.UPDATE_TIMESTAMP,
				UPDATE_USER = r_details.UPDATE_USER,
				QUANTITY = r_details.QUANTITY,
				SUBMIT_COST_SHARING = r_details.SUBMIT_COST_SHARING,
				SUBAWARD_NUMBER = to_number(r_details.SUBAWARD_NUMBER)
			WHERE BUDGET_ID = li_budget_id 
			and BUDGET_PERIOD_NUMBER = li_bud_period
			and LINE_ITEM_NUMBER = r_details.LINE_ITEM_NUMBER;
		
		end if;
		
			
		

     EXCEPTION
     WHEN OTHERS THEN                   
		dbms_output.put_line('Missing data in BUDGET or BUDGET_PERIODS while inserting into BUDGET_DETAILS , Proposal Number is '||ls_proposal_number||' ,Version Number is '||r_details.VERSION_NUMBER||' and Budget Period is '||r_details.BUDGET_PERIOD||' .'||substr(sqlerrm,1,200));
     END;
 
 IF c_cal_amt%ISOPEN THEN
          CLOSE c_cal_amt;
       END IF;  
             OPEN c_cal_amt(r_details.PROPOSAL_NUMBER,r_details.VERSION_NUMBER,r_details.BUDGET_PERIOD,r_details.LINE_ITEM_NUMBER);
             LOOP
             FETCH c_cal_amt INTO r_cal_amt;
             EXIT WHEN c_cal_amt%NOTFOUND;
             SELECT SEQ_BUDGET_DETAILS_CAL_AMTS_ID.NEXTVAL INTO li_bud_det_cal_id FROM DUAL;
                
                BEGIN     
				
				select count(budget_details_cal_amts_id) into li_count from BUDGET_DETAILS_CAL_AMTS 
				WHERE BUDGET_ID = li_budget_id 
				and BUDGET_PERIOD_NUMBER = li_bud_period 
				and LINE_ITEM_NUMBER = r_cal_amt.LINE_ITEM_NUMBER
				and RATE_CLASS_CODE = r_cal_amt.RATE_CLASS_CODE
				and RATE_TYPE_CODE = r_cal_amt.RATE_TYPE_CODE;
				
				if li_count = 0 then -- INSERT
				       INSERT INTO BUDGET_DETAILS_CAL_AMTS(BUDGET_DETAILS_CAL_AMTS_ID,BUDGET_ID,BUDGET_PERIOD_NUMBER,BUDGET_PERIOD,LINE_ITEM_NUMBER,RATE_CLASS_CODE,RATE_TYPE_CODE,APPLY_RATE_FLAG,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_DETAILS_ID,OBJ_ID,RATE_TYPE_DESCRIPTION)
					   VALUES(li_bud_det_cal_id,li_budget_id,li_bud_period,r_cal_amt.BUDGET_PERIOD,r_cal_amt.LINE_ITEM_NUMBER,r_cal_amt.RATE_CLASS_CODE,r_cal_amt.RATE_TYPE_CODE,r_cal_amt.APPLY_RATE_FLAG,r_cal_amt.CALCULATED_COST,r_cal_amt.CALCULATED_COST_SHARING,r_cal_amt.UPDATE_TIMESTAMP,r_cal_amt.UPDATE_USER,li_ver_nbr,li_budget_details_id,SYS_GUID(),ls_rate_type_desc);
							   
				else -- UPDATE
				
				UPDATE BUDGET_DETAILS_CAL_AMTS SET				
				APPLY_RATE_FLAG = r_cal_amt.APPLY_RATE_FLAG,
				CALCULATED_COST = r_cal_amt.CALCULATED_COST,
				CALCULATED_COST_SHARING = r_cal_amt.CALCULATED_COST_SHARING,
				UPDATE_TIMESTAMP = r_cal_amt.UPDATE_TIMESTAMP,
				UPDATE_USER = r_cal_amt.UPDATE_USER
				WHERE BUDGET_ID = li_budget_id 
				and BUDGET_PERIOD_NUMBER = li_bud_period 
				and LINE_ITEM_NUMBER = r_cal_amt.LINE_ITEM_NUMBER
				and RATE_CLASS_CODE = r_cal_amt.RATE_CLASS_CODE
				and RATE_TYPE_CODE = r_cal_amt.RATE_TYPE_CODE;				
				
				end if;
				

			   EXCEPTION 
                WHEN OTHERS THEN                   
                dbms_output.put_line('Missing data in BUDGET_DETAILS_CAL_AMTS ,Proposal Number is '||r_details.PROPOSAL_NUMBER||' ,Version Number is '||r_details.VERSION_NUMBER||' and Budget Period is '||r_details.BUDGET_PERIOD||' .'||substr(sqlerrm,1,200));
                END;
                
                END LOOP;
                CLOSE c_cal_amt;   
   
                END LOOP;
                CLOSE c_details;               
               
       IF c_rate_base%ISOPEN THEN
          CLOSE c_rate_base;
       END IF;
             OPEN c_rate_base;
             LOOP
             FETCH c_rate_base INTO r_rate_base;
             EXIT WHEN c_rate_base%NOTFOUND;    
             
              SELECT SEQ_BUDGET_RATE_AND_BASE_ID.NEXTVAL INTO li_bud_rate_base_id FROM DUAL;
              select to_number(r_rate_base.PROPOSAL_NUMBER) into ls_prop_num from dual;
              
                 BEGIN       
					 SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_rate_base.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_prop_num)AND VER_NBR =r_rate_base.VERSION_NUMBER);
					 SELECT BUDGET_PERIOD_NUMBER INTO li_bud_period FROM BUDGET_PERIODS WHERE BUDGET_ID=li_budget_id and budget_period=r_rate_base.BUDGET_PERIOD;
					 begin
					 SELECT BUDGET_DETAILS_CAL_AMTS_ID,BUDGET_DETAILS_ID INTO li_fk_det_cal_id,li_fk_bud_details_id FROM BUDGET_DETAILS_CAL_AMTS WHERE BUDGET_ID=li_budget_id AND BUDGET_PERIOD=r_rate_base.BUDGET_PERIOD AND LINE_ITEM_NUMBER=r_rate_base.LINE_ITEM_NUMBER AND RATE_CLASS_CODE=r_rate_base.RATE_CLASS_CODE AND RATE_TYPE_CODE=r_rate_base.RATE_TYPE_CODE;
					 exception
					 when no_data_found then
					 li_fk_det_cal_id:=null;
					 li_fk_bud_details_id:=null;
					 end;
					 
					 select count(budget_rate_and_base_id) into li_count from BUDGET_RATE_AND_BASE
					 where	BUDGET_ID = li_budget_id
					 and	BUDGET_PERIOD_NUMBER = li_bud_period
					 and	LINE_ITEM_NUMBER = r_rate_base.LINE_ITEM_NUMBER
					 and	RATE_NUMBER = r_rate_base.RATE_NUMBER
					 and	RATE_CLASS_CODE = r_rate_base.RATE_CLASS_CODE
					 and	RATE_TYPE_CODE = r_rate_base.RATE_TYPE_CODE
					 and	START_DATE = r_rate_base.START_DATE;				 
					 
					 if li_count = 0 then -- INSERT
						INSERT INTO BUDGET_RATE_AND_BASE(BUDGET_RATE_AND_BASE_ID,BUDGET_PERIOD_NUMBER,BUDGET_ID,BUDGET_PERIOD,LINE_ITEM_NUMBER,RATE_NUMBER,START_DATE,END_DATE,RATE_CLASS_CODE,RATE_TYPE_CODE,ON_OFF_CAMPUS_FLAG,APPLIED_RATE,BASE_COST,BASE_COST_SHARING,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_DETAILS_CAL_AMTS_ID,BUDGET_DETAILS_ID,OBJ_ID)
						VALUES(li_bud_rate_base_id,li_bud_period,li_budget_id,r_rate_base.BUDGET_PERIOD,r_rate_base.LINE_ITEM_NUMBER,r_rate_base.RATE_NUMBER,r_rate_base.START_DATE,r_rate_base.END_DATE,r_rate_base.RATE_CLASS_CODE,r_rate_base.RATE_TYPE_CODE,r_rate_base.ON_OFF_CAMPUS_FLAG,r_rate_base.APPLIED_RATE,r_rate_base.BASE_COST,r_rate_base.BASE_COST_SHARING,r_rate_base.CALCULATED_COST,r_rate_base.CALCULATED_COST_SHARING,r_rate_base.UPDATE_TIMESTAMP,r_rate_base.UPDATE_USER,li_ver_nbr,li_fk_det_cal_id,li_fk_bud_details_id ,SYS_GUID());
										
					 else -- UPDATE
						UPDATE BUDGET_RATE_AND_BASE SET
						END_DATE = r_rate_base.END_DATE,
						ON_OFF_CAMPUS_FLAG = r_rate_base.ON_OFF_CAMPUS_FLAG,
						APPLIED_RATE = r_rate_base.APPLIED_RATE,
						BASE_COST = r_rate_base.BASE_COST,
						BASE_COST_SHARING = r_rate_base.BASE_COST_SHARING,
						CALCULATED_COST = r_rate_base.CALCULATED_COST,
						CALCULATED_COST_SHARING = r_rate_base.CALCULATED_COST_SHARING,
						UPDATE_TIMESTAMP = r_rate_base.UPDATE_TIMESTAMP,
						UPDATE_USER = r_rate_base.UPDATE_USER
						WHERE BUDGET_ID = li_budget_id
						 and	BUDGET_PERIOD_NUMBER = li_bud_period
						 and	LINE_ITEM_NUMBER = r_rate_base.LINE_ITEM_NUMBER
						 and	RATE_NUMBER = r_rate_base.RATE_NUMBER
						 and	RATE_CLASS_CODE = r_rate_base.RATE_CLASS_CODE
						 and	RATE_TYPE_CODE = r_rate_base.RATE_TYPE_CODE
						 and	START_DATE = r_rate_base.START_DATE;
						
					 
					 end if;
					 
					 					
					
				EXCEPTION 
                WHEN OTHERS THEN                   
                dbms_output.put_line('Missing data in BUDGET or BUDGET_PERIODS while inserting into BUDGET_RATE_AND_BASE , Proposal Number is '||r_rate_base.PROPOSAL_NUMBER||' ,Version Number is '||r_rate_base.VERSION_NUMBER||' and Budget Period is '||r_rate_base.BUDGET_PERIOD||' .'||substr(sqlerrm,1,200));
                END;
           
    END LOOP;
    CLOSE c_rate_base;
        
       EXCEPTION 
      WHEN OTHERS THEN                   
      dbms_output.put_line('Error Occoured '||substr(sqlerrm,1,200));
      END;     
    
/
select ' Ended BUDGET_DETAILS,BUDGET_DETAILS_CAL_AMTS,BUDGET_RATE_AND_BASE  ' from dual
/