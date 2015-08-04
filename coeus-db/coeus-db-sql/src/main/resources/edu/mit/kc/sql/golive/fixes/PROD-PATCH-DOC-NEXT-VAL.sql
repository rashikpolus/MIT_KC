declare
cursor c_data is
  select protocol_id, protocol_number,sequence_number,document_number,substr(protocol_number,11,1) as proto_typ from protocol
  where substr(protocol_number,1,10) in (select substr(protocol_number,1,10) 
  from osp$protocol@coeus.kuali)
  and active = 'Y';
 r_data c_data%rowtype;
 li_max NUMBER(6);
 li_count NUMBER;
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
   -- actionId 
        select max(action_id) into li_max from protocol_actions 
        where protocol_id =  r_data.protocol_id
        and  protocol_number = r_data.protocol_number
        and sequence_number = r_data.sequence_number;
        
         if li_max is not null then
          li_max := li_max + 1;         
          select count(document_number) into li_count from document_nextvalue 
          where document_number = r_data.document_number
          and property_name = 'actionId';  
          
          if li_count = 0 then
            INSERT INTO document_nextvalue(document_number,property_name,next_value,update_timestamp,update_user,ver_nbr,obj_id,
            document_next_value_type)
            VALUES(r_data.document_number,'actionId',li_max,sysdate,'admin',1,sys_guid(),'DOC');
            
          else
          
            UPDATE document_nextvalue SET next_value = li_max
            where document_number = r_data.document_number
            and property_name = 'actionId';
         
          end if;
						
		 end if;
		
     
     --submissionNumber
        select max(submission_number) into li_max from protocol_submission 
        where protocol_id =  r_data.protocol_id
        and  protocol_number = r_data.protocol_number
        and sequence_number = r_data.sequence_number;
        
         if li_max is not null then
          li_max := li_max + 1;         
           select count(document_number) into li_count from document_nextvalue 
           where document_number = r_data.document_number
           and property_name = 'submissionNumber'; 
          
          if li_count = 0 then
             INSERT INTO document_nextvalue(document_number,property_name,next_value,update_timestamp,update_user,ver_nbr,obj_id,document_next_value_type)
            VALUES(r_data.document_number,'submissionNumber',li_max,sysdate,'admin',1,sys_guid(),'DOC'); 
            
          else
          
            UPDATE document_nextvalue SET next_value = li_max
            where document_number = r_data.document_number
            and property_name = 'submissionNumber';
         
          end if;
						
		 end if;

    --nextAmendValue
        select max(substr(protocol_number,-1)) into li_max 
        from protocol
        where protocol_number  like r_data.protocol_number||'%'
        and substr(protocol_number,11,1) = 'A';
        
         if li_max is not null then
          li_max := li_max + 1;         
             select count(document_number) into li_count from document_nextvalue 
             where document_number = r_data.document_number
             and property_name = 'nextAmendValue';    
          
          if li_count = 0 and r_data.proto_typ is null then
             INSERT INTO document_nextvalue(document_number,property_name,next_value,update_timestamp,update_user,ver_nbr,obj_id,document_next_value_type)
             VALUES(r_data.document_number,'nextAmendValue',li_max,sysdate,'admin',1,sys_guid(),'DOC'); 
            
          else
          
            UPDATE document_nextvalue SET next_value = li_max
            where document_number = r_data.document_number
            and property_name = 'nextAmendValue';
         
          end if;
						
		 end if;

    --nextRenewValue
        select max(substr(protocol_number,-1)) into li_max 
        from protocol
        where protocol_number  like r_data.protocol_number||'%'
        and substr(protocol_number,11,1) = 'R';
        
         if li_max is not null then
          li_max := li_max + 1;         
             select count(document_number) into li_count from document_nextvalue 
             where document_number = r_data.document_number
             and property_name = 'nextRenewValue';      
          
          if li_count = 0 and r_data.proto_typ is null then
             INSERT INTO document_nextvalue(document_number,property_name,next_value,update_timestamp,update_user,ver_nbr,obj_id,document_next_value_type)
             VALUES(r_data.document_number,'nextRenewValue',li_max,sysdate,'admin',1,sys_guid(),'DOC'); 
            
          else
          
            UPDATE document_nextvalue SET next_value = li_max
            where document_number = r_data.document_number
            and property_name = 'nextRenewValue';
         
          end if;
						
		 end if;
  
  
  end loop;
  close c_data;
  
end;
/
 
commit;
 