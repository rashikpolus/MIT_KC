create index awd_cust_i1 on award_custom_data(award_number,sequence_number,custom_attribute_id)
/
create table temp_custom(
award_id NUMBER(22,0),
award_number VARCHAR2(12),
sequence_number NUMBER(8,0))
/
insert into temp_custom(award_id,award_number,sequence_number)
select distinct award_id,award_number,sequence_number from award_custom_data
/
commit
/
declare
li_custom_id number(12,0);
li_count number;
ls_award_number VARCHAR2(12);
li_seq number(4,0);

cursor c_awd_custom is
select award_id,award_number,sequence_number from temp_custom
order by award_number,sequence_number;
r_awd_custom c_awd_custom%rowtype;

cursor c_custom(as_award_number varchar2,as_seq number) is
select c.ID,c.NAME from custom_attribute c inner join osp$custom_data_element_usage@coeus.kuali oc
on c.NAME=oc.COLUMN_NAME
where oc.module_code=1
and c.ID not in(select custom_attribute_id from award_custom_data where award_number=as_award_number and sequence_number=as_seq);
r_custom c_custom%rowtype;

begin

if c_awd_custom%isopen then
close c_awd_custom;
end if;
open c_awd_custom;
loop
fetch c_awd_custom into r_awd_custom;
exit when c_awd_custom%notfound;
       
ls_award_number:=r_awd_custom.award_number;
li_seq:=r_awd_custom.sequence_number;
       
       if c_custom%isopen then
        close c_custom;
       end if;
       open c_custom(ls_award_number,li_seq);
       loop
       fetch c_custom into r_custom;
       exit when c_custom%notfound;
       
           li_custom_id:=r_custom.ID;
       
               
               
               select count(award_custom_data_id) into li_count from award_custom_data 
               where award_number=r_awd_custom.AWARD_NUMBER and  sequence_number=r_awd_custom.SEQUENCE_NUMBER and CUSTOM_ATTRIBUTE_ID=li_custom_id;
               
               if li_count=0 then
               
                   insert into award_custom_data(AWARD_CUSTOM_DATA_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CUSTOM_ATTRIBUTE_ID,VALUE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
                   values(SEQ_AWARD_CUSTOM_DATA_ID.NEXTVAL,r_awd_custom.AWARD_ID,r_awd_custom.AWARD_NUMBER,r_awd_custom.SEQUENCE_NUMBER,li_custom_id,null,sysdate,'admin',1,sys_guid());
                
                end if;   
                 
                
   
        
        end loop;
        close c_custom;


end loop;
close c_awd_custom;
end;
/
drop table temp_custom
/ 
drop index awd_cust_i1
/
