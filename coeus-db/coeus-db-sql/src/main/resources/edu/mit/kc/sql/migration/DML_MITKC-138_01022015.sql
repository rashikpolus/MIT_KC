set serveroutput on
/
DROP TABLE TEMP_NEGOTIATION_ID
/
CREATE TABLE TEMP_NEGOTIATION_ID(
NEGOTIATION_NUMBER VARCHAR2(8 BYTE),
NEGOTIATION_ID NUMBER(22,0))
/
INSERT INTO TEMP_NEGOTIATION_ID(NEGOTIATION_NUMBER,NEGOTIATION_ID)
SELECT ASSOCIATED_DOCUMENT_ID,NEGOTIATION_ID FROM NEGOTIATION
/
ALTER TABLE NEGOTIATION_ATTACHMENT DISABLE CONSTRAINT NEGOTIATION_ATTACHMENT_FK2
/
DELETE FROM ATTACHMENT_FILE WHERE FILE_ID IN(SELECT FILE_ID FROM NEGOTIATION_ATTACHMENT)
/
DELETE FROM NEGOTIATION_ATTACHMENT
/
DELETE FROM NEGOTIATION_ACTIVITY
/
ALTER TABLE NEGOTIATION_ATTACHMENT ENABLE CONSTRAINT NEGOTIATION_ATTACHMENT_FK2
/
declare
li_count number;

begin

select count(*) into li_count from user_tables where table_name='TEMP_NEGOTIATION_ACT_ID';
if li_count=0 then
execute immediate('CREATE TABLE TEMP_NEGOTIATION_ACT_ID(NEGOTIATION_NUMBER VARCHAR2(8 BYTE),ACTIVITY_NUMBER NUMBER(3,0),NEGOTIATION_ACTIVITY_ID NUMBER(22,0))');
else
execute immediate('drop table TEMP_NEGOTIATION_ACT_ID');
execute immediate('CREATE TABLE TEMP_NEGOTIATION_ACT_ID(NEGOTIATION_NUMBER VARCHAR2(8 BYTE),ACTIVITY_NUMBER NUMBER(3,0),NEGOTIATION_ACTIVITY_ID NUMBER(22,0))');
end if;

select count(*) into li_count from user_tables where table_name='TEMP_NEGOTIATION_DOC';
if li_count=0 then
execute immediate('create table TEMP_NEGOTIATION_DOC as SELECT NEGOTIATION_NUMBER,ACTIVITY_NUMBER,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,MIME_TYPE FROM OSP$NEGOTIATION_DOCUMENTS@Coeus.Kuali');
else
execute immediate('drop table TEMP_NEGOTIATION_DOC');
execute immediate('create table TEMP_NEGOTIATION_DOC as SELECT NEGOTIATION_NUMBER,ACTIVITY_NUMBER,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,MIME_TYPE FROM OSP$NEGOTIATION_DOCUMENTS@Coeus.Kuali');
end if;

end;
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_act_id NUMBER(22,0);
li_neg_id NUMBER(22,0);
li_act_typ_id  NUMBER(22,0);
ls_loc_type VARCHAR2(9);
li_loc_id NUMBER(22,0);
ls_act_typ_code VARCHAR2(3);
CURSOR c_neg_activity IS
SELECT NEGOTIATION_NUMBER,ACTIVITY_NUMBER,substrb(DESCRIPTION,1,2000)DESCRIPTION,NEGOTIATION_ACT_TYPE_CODE,DOC_FILE_ADDRESS,FOLLOWUP_DATE,CREATE_DATE,ACTIVITY_DATE,UPDATE_TIMESTAMP,UPDATE_USER,RESTRICTED_VIEW FROM OSP$NEGOTIATION_ACTIVITIES@Coeus.Kuali order by NEGOTIATION_NUMBER,ACTIVITY_NUMBER;
r_neg_activity c_neg_activity%ROWTYPE;

BEGIN

IF c_neg_activity%ISOPEN THEN
CLOSE c_neg_activity;
END IF;
OPEN c_neg_activity;
LOOP
FETCH c_neg_activity INTO r_neg_activity;
EXIT WHEN c_neg_activity%NOTFOUND;
li_loc_id := 1;-- harcorded
SELECT NEGOTIATION_ACTIVITY_S.NEXTVAL INTO li_act_id FROM DUAL;
begin
SELECT NEGOTIATION_ID INTO li_neg_id FROM TEMP_NEGOTIATION_ID WHERE  NEGOTIATION_NUMBER=r_neg_activity.NEGOTIATION_NUMBER;
exception
when others then
dbms_output.put_line('Error while fetching NEGOTIATION_ID from TEMP_NEGOTIATION_ID using NEGOTIATION_NUMBER:'||r_neg_activity.NEGOTIATION_NUMBER||'and error is:'||sqlerrm);
end;

BEGIN

INSERT INTO TEMP_NEGOTIATION_ACT_ID(NEGOTIATION_NUMBER,ACTIVITY_NUMBER,NEGOTIATION_ACTIVITY_ID)
VALUES(r_neg_activity.NEGOTIATION_NUMBER,r_neg_activity.ACTIVITY_NUMBER,li_act_id);

INSERT INTO NEGOTIATION_ACTIVITY(NEGOTIATION_ACTIVITY_ID,NEGOTIATION_ID,LOCATION_ID,ACTIVITY_TYPE_ID,START_DATE,END_DATE,CREATE_DATE,FOLLOWUP_DATE,LAST_MODIFIED_USER,LAST_MODIFIED_DATE,DESCRIPTION,RESTRICTED,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_act_id,li_neg_id,li_loc_id,r_neg_activity.NEGOTIATION_ACT_TYPE_CODE,r_neg_activity.ACTIVITY_DATE,null,r_neg_activity.CREATE_DATE,r_neg_activity.FOLLOWUP_DATE,lower(r_neg_activity.UPDATE_USER),r_neg_activity.UPDATE_TIMESTAMP,r_neg_activity.DESCRIPTION,r_neg_activity.RESTRICTED_VIEW,r_neg_activity.UPDATE_TIMESTAMP,r_neg_activity.UPDATE_USER,li_ver_nbr,SYS_GUID);

EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('ERROR IN NEGOTIATION_ACTIVITY,NEGOTIATION_ID:'||r_neg_activity.NEGOTIATION_NUMBER);
END;
END LOOP;
CLOSE c_neg_activity;
END;
/
commit
/
declare
ls_start_date negotiation_activity.start_date%type;
cursor c_nego is
  select t2.negotiation_number, t2.activity_number, t2.negotiation_activity_id,t1.start_date
  from negotiation_activity t1
  inner join temp_negotiation_act_id t2 on t2.negotiation_activity_id = t1.negotiation_activity_id
  order by t2.negotiation_activity_id;
  r_nego c_nego%rowtype;
  
  li_nego_loc_type_code	number(3,0);
  ls_effective_date	date;
  
begin
  open c_nego;
  loop
  fetch c_nego into r_nego;
  exit when c_nego%notfound;
  
  begin
    select ACTIVITY_DATE into ls_start_date from osp$negotiation_activities@coeus.kuali
    where NEGOTIATION_NUMBER = r_nego.negotiation_number
    and activity_number = ( r_nego.activity_number + 1);
    
  exception
  when others then
  ls_start_date := null;
  end;
  
   begin 
  if ls_start_date is null then  
          select t1.negotiation_location_type_code, t1.effective_date
          into li_nego_loc_type_code,ls_effective_date
          FROM osp$negotiation_location@coeus.kuali t1
          where t1.negotiation_number = r_nego.negotiation_number
          and t1.location_number = ( select min(location_number) from osp$negotiation_location@coeus.kuali t2 
                                     where t2.negotiation_number = t1.negotiation_number
                                     and  t2.effective_date  >= r_nego.start_date);  
                                     
   else                                   
        select t1.negotiation_location_type_code, t1.effective_date
        into li_nego_loc_type_code,ls_effective_date
        FROM osp$negotiation_location@coeus.kuali t1
        where t1.negotiation_number = r_nego.negotiation_number
        and t1.location_number = ( select min(location_number) from osp$negotiation_location@coeus.kuali t2 
                                   where t2.negotiation_number = t1.negotiation_number
                                   and  t2.effective_date  >= to_date(r_nego.start_date)
                                   and  t2.effective_date <= to_date(ls_start_date));  
   
   end if;  
   update negotiation_activity set END_DATE = ls_effective_date, LOCATION_ID = li_nego_loc_type_code
   where negotiation_activity_id =  r_nego.negotiation_activity_id;      
  -- dbms_output.put_line(r_nego.negotiation_activity_id||','|| r_nego.negotiation_number||',  '||li_nego_loc_type_code||' , '||'Updated');
   
   exception
   when others then     
    --dbms_output.put_line( r_nego.negotiation_number||',  '||r_nego.start_date||' , '||sqlerrm);
   continue;
   end;
    
  end loop;
  close c_nego;

end;
/
commit
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_attachment_id NUMBER(22,0);
li_seq_attachment NUMBER(22,0);
ls_restricted CHAR(1 BYTE):='Y';
ls_content_type VARCHAR2(255 BYTE);
li_neg_id  NUMBER(22,0);
li_act_id NUMBER(22,0);
CURSOR c_attachment IS

SELECT NEGOTIATION_NUMBER,ACTIVITY_NUMBER,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,MIME_TYPE FROM TEMP_NEGOTIATION_DOC;
r_attachment c_attachment%ROWTYPE;

BEGIN

IF c_attachment%ISOPEN THEN
CLOSE c_attachment;
END IF;
OPEN c_attachment;
LOOP
FETCH c_attachment INTO r_attachment;
EXIT WHEN c_attachment%NOTFOUND;

SELECT NEGOTIATION_ATTACHMENT_S.NEXTVAL INTO li_attachment_id FROM DUAL;
SELECT SEQ_ATTACHMENT_ID.NEXTVAL INTO li_seq_attachment FROM DUAL;


BEGIN

ls_content_type:=r_attachment.MIME_TYPE;
IF ls_content_type IS NULL THEN  
ls_content_type:='application/octet-stream';
END IF;
begin
SELECT NEGOTIATION_ID  INTO li_neg_id FROM TEMP_NEGOTIATION_ID WHERE NEGOTIATION_NUMBER=r_attachment.NEGOTIATION_NUMBER;
exception
when others then
dbms_output.put_line('Error while fetching NEGOTIATION_ID from TEMP_NEGOTIATION_ID using NEGOTIATION_NUMBER:'||r_attachment.NEGOTIATION_NUMBER||'and error is:'||sqlerrm);
end;
begin
SELECT NEGOTIATION_ACTIVITY_ID INTO li_act_id FROM  TEMP_NEGOTIATION_ACT_ID WHERE NEGOTIATION_NUMBER=r_attachment.NEGOTIATION_NUMBER AND ACTIVITY_NUMBER=r_attachment.ACTIVITY_NUMBER;
exception
when others then
dbms_output.put_line('Error while fetching NEGOTIATION_ACTIVITY_ID from TEMP_NEGOTIATION_ACT_ID using NEGOTIATION_NUMBER:'||r_attachment.NEGOTIATION_NUMBER||'and ACTIVITY_NUMBER:'||r_attachment.ACTIVITY_NUMBER||'and error is:'||sqlerrm);
end;
INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
VALUES(li_seq_attachment,0,r_attachment.FILE_NAME,ls_content_type,r_attachment.DOCUMENT,li_ver_nbr,r_attachment.UPDATE_TIMESTAMP,r_attachment.UPDATE_USER,SYS_GUID());

INSERT INTO NEGOTIATION_ATTACHMENT(ATTACHMENT_ID,ACTIVITY_ID,DESCRIPTION,RESTRICTED,FILE_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_attachment_id,li_act_id,null,ls_restricted,li_seq_attachment,r_attachment.UPDATE_TIMESTAMP,r_attachment.UPDATE_USER,li_ver_nbr,SYS_GUID());

EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('ERROR IN NEGOTIATION_ATTACHMENT,NEGOTIATION_NUMBER:'||r_attachment.NEGOTIATION_NUMBER || 'ACTIVITY_ID:'||r_attachment.ACTIVITY_NUMBER||'-'||sqlerrm);

END;
END LOOP;
CLOSE c_attachment;
END;
/