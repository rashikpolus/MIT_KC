SET DEFINE OFF;
Declare
li_ret number;
begin
Insert into CITI_TRAINING (FIRST_NAME,LAST_NAME,EMAIL,CURRICULUM,TRAINING_GROUP,SCORE,PASSING_SCORE,STAGE_NUMBER,STAGE,DATE_COMPLETED,USER_NAME,CUSTOM_FIELD1,CUSTOM_FIELD2,UPDATE_TIMESTAMP) 
values ('Karl','Seidman','test@mail.edu',null,'BIOMEDICAL RESEARCH INVESTIGATORS',null,null,'3',null,sysdate,'seidman',null,'900018397',sysdate); 
li_ret :=kc_package_citi.fn_populate_pers_training;
dbms_output.put_line(li_ret);
END ;