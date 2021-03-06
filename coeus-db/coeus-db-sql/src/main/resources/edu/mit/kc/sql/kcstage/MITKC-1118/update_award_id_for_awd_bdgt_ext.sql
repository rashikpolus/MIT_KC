CREATE TABLE AWARD_BUDGET_EXT_BAK(
BUDGET_ID     NUMBER(12),                                                                                                                                                                                  
AWARD_BUDGET_STATUS_CODE  VARCHAR2(3),                                                                                                                                                                                   
AWARD_BUDGET_TYPE_CODE  VARCHAR2(3),                                                                                                                                                                                   
VER_NBR                NUMBER(8),                                                                                                                                                                                    
UPDATE_TIMESTAMP       DATE,                                                                                                                                                                                       
UPDATE_USER            VARCHAR2(60),                                                                                                                                                                                  
OBLIGATED_AMOUNT       NUMBER(12,2) ,                                                                                                                                                                                 
BUDGET_INITIATOR       VARCHAR2(60) ,                                                                                                                                                                                 
DESCRIPTION            VARCHAR2(255),                                                                                                                                                                                 
DOCUMENT_NUMBER        VARCHAR2(40),                                                                                                                                                                                 
OBJ_ID                 VARCHAR2(36),                                                                                                                                                                            
AWARD_ID               NUMBER(22))
/
INSERT INTO AWARD_BUDGET_EXT_BAK(BUDGET_ID,AWARD_BUDGET_STATUS_CODE,AWARD_BUDGET_TYPE_CODE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,
OBLIGATED_AMOUNT,BUDGET_INITIATOR,DESCRIPTION,DOCUMENT_NUMBER,OBJ_ID,AWARD_ID)	 
SELECT BUDGET_ID,AWARD_BUDGET_STATUS_CODE,AWARD_BUDGET_TYPE_CODE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,
OBLIGATED_AMOUNT,BUDGET_INITIATOR,DESCRIPTION,DOCUMENT_NUMBER,OBJ_ID,AWARD_ID FROM AWARD_BUDGET_EXT
/
CREATE TABLE MISSING_AWARD_BUDGET (
AWARD_NUMBER VARCHAR2(12),
SEQUENCE_NUMBER NUMBER(4),
FROM_SEQUENCE NUMBER(4)
)
/
CREATE TABLE TEMP_AWARD_ID_MAPPING (
OLD_AWARD_ID NUMBER(12),
NEW_AWARD_ID NUMBER(12)
)
/
INSERT INTO MISSING_AWARD_BUDGET(AWARD_NUMBER,SEQUENCE_NUMBER,FROM_SEQUENCE)
select a0.award_number , a0.sequence_number, a1.sequence_number as from_sequence  
from  award a0
inner join
(
    select t0.award_number , max(t0.sequence_number) sequence_number from 
    (
    select t1.award_number , t1.sequence_number
    from award t1 inner join award_budget_ext t2 on t1.award_id = t2.award_id
    ) t0 group by t0.award_number order by t0.award_number
) a1 
on a0.award_number = a1.award_number and a0.sequence_number > a1.sequence_number
ORDER by a0.award_number , a0.sequence_number
/
commit
/
declare
	li_budget_id BUDGET.BUDGET_ID%type;
	li_new_award AWARD.AWARD_ID%type;
	li_old_award AWARD.AWARD_ID%type;
	cursor c_data is
	select AWARD_NUMBER,SEQUENCE_NUMBER,FROM_SEQUENCE FROM MISSING_AWARD_BUDGET order by AWARD_NUMBER,SEQUENCE_NUMBER;
	r_data c_data%rowtype;
begin
	open c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
	
	begin
			begin
			
				SELECT AWARD_ID INTO li_new_award
				FROM AWARD 
				WHERE AWARD_NUMBER = r_data.award_number
				AND SEQUENCE_NUMBER = r_data.sequence_number;
			exception
			when others then
			dbms_output.put_line('Error in  AWARD, AWARD_NUMBER:'||r_data.award_number||'SEQUENCE_NUMBER '||r_data.sequence_number||' and the error is'||substr(sqlerrm,1,100));
			continue;
			end;
			
			begin
			
				SELECT AWARD_ID INTO li_old_award
				FROM AWARD 
				WHERE AWARD_NUMBER  = r_data.award_number
				AND SEQUENCE_NUMBER = r_data.FROM_SEQUENCE;
			exception
			when others then
			dbms_output.put_line('Error in  AWARD, AWARD_NUMBER:'||r_data.award_number||'FROM_SEQUENCE '||r_data.FROM_SEQUENCE||' and the error is'||substr(sqlerrm,1,100));
			continue;
			end;
			
			INSERT INTO TEMP_AWARD_ID_MAPPING(OLD_AWARD_ID,NEW_AWARD_ID)
			VALUES(li_old_award,li_new_award);
			
			commit;
			
			UPDATE award_budget_ext SET AWARD_ID = li_new_award WHERE AWARD_ID = li_old_award;
			
	exception
	when others then
	dbms_output.put_line('Error in  UPDATE, AWARD_NUMBER:'||r_data.award_number||'SEQUENCE_NUMBER '||r_data.sequence_number||' and the error is'||substr(sqlerrm,1,100));
	end;
	
	
	end loop;
	close c_data;
end;
/
commit
/