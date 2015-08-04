Declare
li_number number;
li_count number;
BEGIN

delete from AWARD_APPROVED_SUBAWARDS where AWARD_ID = 1508;
commit;

Insert into AWARD_APPROVED_SUBAWARDS (AWARD_APPROVED_SUBAWARD_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ORGANIZATION_NAME,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ORGANIZATION_ID,OBJ_ID) 
values (SEQ_AWARD_APPROVED_SUBAWARD_ID.NEXTVAL,1508,'000153-00001',1,'Georgia Tech',25542,sysdate,'OSPA',1,null,sys_guid());
Insert into AWARD_APPROVED_SUBAWARDS (AWARD_APPROVED_SUBAWARD_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ORGANIZATION_NAME,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ORGANIZATION_ID,OBJ_ID) 
values (SEQ_AWARD_APPROVED_SUBAWARD_ID.NEXTVAL,1508,'000153-00001',2,'Georgia Tech',45542,sysdate,'OSPA',1,null,sys_guid());

update SUBAWARD set END_DATE = trunc( sysdate) + 30 where subaward_code='140';
li_number:=kc_sub_notifications_pkg.fn_sub_end_prior_notification();
update SUBAWARD set END_DATE = trunc( sysdate) - 30 where subaward_code='140';
li_number:=kc_sub_notifications_pkg.fn_sub_end_after_notification();
END;
/
--set serveroutput on;

