alter table document_access disable constraint UQ_DOCUMENT_ACCESS1
/
alter table document_access disable constraint UQ_DOCUMENT_ACCESS2
/
declare
li_count number;
begin
  select  count(table_name) into li_count  from user_tables   where table_name = 'OSP$EPS_PROP_USER_ROLES';
  if li_count = 0 then
    execute immediate('
      CREATE TABLE OSP$EPS_PROP_USER_ROLES(	
    PROPOSAL_NUMBER VARCHAR2(8), 
    USER_ID VARCHAR2(8 BYTE), 
    ROLE_ID NUMBER(5,0) , 
    UPDATE_TIMESTAMP DATE, 
    UPDATE_USER VARCHAR2(8)
    )');
  end if;
       
end;
/
declare
li_count NUMBER;
begin

   select count(*) into li_count from OSP$EPS_PROP_USER_ROLES;
   if li_count = 0 then    
      INSERT INTO OSP$EPS_PROP_USER_ROLES(
      PROPOSAL_NUMBER,
      ROLE_ID,
      USER_ID,
      UPDATE_TIMESTAMP,
      UPDATE_USER
      )
      SELECT to_number(PROPOSAL_NUMBER),
      ROLE_ID,
      USER_ID,
      UPDATE_TIMESTAMP,
      UPDATE_USER
      FROM OSP$EPS_PROP_USER_ROLES@coeus.kuali;
      
      commit;	
      update OSP$EPS_PROP_USER_ROLES set PROPOSAL_NUMBER = to_number(PROPOSAL_NUMBER);
      commit;
  end if;
   
end;
/
CREATE INDEX OSP$EPS_PROP_USER_ROLES_I ON OSP$EPS_PROP_USER_ROLES(PROPOSAL_NUMBER,ROLE_ID,USER_ID)
/
delete from DOCUMENT_ACCESS where DOC_HDR_ID IN(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL t1 inner join OSP$EPS_PROP_USER_ROLES e  on t1.proposal_number = e.PROPOSAL_NUMBER)
/
commit
/
DECLARE 
ls_mbr_id VARCHAR2(40);
ls_role_nm DOCUMENT_ACCESS.ROLE_NM%TYPE;
ls_nmspc_cd krim_role_t.nmspc_cd%type;

CURSOR c_module_role is
	SELECT distinct t1.PROPOSAL_NUMBER, t1.document_number,lower(e.USER_ID) USER_ID,e.ROLE_ID,r.role_name,e.UPDATE_USER,e.UPDATE_TIMESTAMP
	FROM OSP$EPS_PROP_USER_ROLES e 
	inner join EPS_PROPOSAL t1 on t1.proposal_number = e.PROPOSAL_NUMBER
	left outer join OSP$ROLE r on r.role_id = e.role_id;

r_module_role c_module_role%ROWTYPE;

li_commit_count NUMBER;

BEGIN	

if    c_module_role%ISOPEN then
close c_module_role;
end if;
OPEN c_module_role; 
LOOP              
FETCH c_module_role INTO r_module_role;
EXIT WHEN c_module_role%NOTFOUND; 


    BEGIN                  
	   select p.PRNCPL_ID INTO ls_mbr_id from KRIM_PRNCPL_T p where p.PRNCPL_NM = r_module_role.USER_ID;
	   
	EXCEPTION
	WHEN OTHERS THEN  
	   dbms_output.put_line('PRNCPL_ID is missing for userID '||r_module_role.USER_ID||' and Proposal Number '||r_module_role.PROPOSAL_NUMBER);
	   continue;
    END;


    BEGIN    
		SELECT t1.kc_roles INTO  ls_role_nm
		FROM kc_coeus_role_mapping t1
		WHERE  upper(t1.coeus_roles) = upper(r_module_role.role_name);	
	                                    
	EXCEPTION
	   WHEN OTHERS THEN
		ls_role_nm := r_module_role.role_name;
    END;
   
   
   BEGIN    
		SELECT t1.nmspc_cd INTO  ls_nmspc_cd
		FROM krim_role_t t1
		WHERE  upper(t1.role_nm) = upper(ls_role_nm);	
	                                    
	EXCEPTION
	   WHEN OTHERS THEN
		ls_nmspc_cd := 'KC-PD';
    END;
   
  
   BEGIN 
		INSERT INTO DOCUMENT_ACCESS(
			DOC_ACCESS_ID,
			DOC_HDR_ID,
			PRNCPL_ID,
			ROLE_NM,
			NMSPC_CD,
			UPDATE_TIMESTAMP,
			UPDATE_USER,
			VER_NBR,
			OBJ_ID
		)
		VALUES(
		   SEQ_DOCUMENT_ACCESS_ID.NEXTVAL,
		   r_module_role.document_number,
		   ls_mbr_id,
		   ls_role_nm,
		   ls_nmspc_cd,
		   r_module_role.update_timestamp,
		   r_module_role.update_user,
		   1,
		   SYS_GUID()
		   );
     		
		li_commit_count := li_commit_count + 1;	
	EXCEPTION
	WHEN OTHERS THEN
	 dbms_output.put_line('Exception while inserting to DOCUMENT_ACCESS , the error is '||substr(sqlerrm,1,200)||', proposal number '||r_module_role.PROPOSAL_NUMBER);
  END;                         

  if li_commit_count = 1000 then
	li_commit_count := 0;
	commit;
	
  end if;
  
END LOOP;
CLOSE c_module_role;   

END;              
/
commit
/
-- script to clean up all approver role from document_access table
declare
cursor c_data is
  select doc_hdr_id
  from document_access
  where NMSPC_CD = 'KC-PD'
  group by doc_hdr_id,prncpl_id having count(prncpl_id) > 1 ;
r_data c_data%rowtype;

begin

  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    delete from document_access where doc_access_id in (
           select t1.doc_access_id
            from (  
                select doc_access_id,doc_hdr_id,prncpl_id, role_nm from document_access
                where doc_hdr_id = r_data.doc_hdr_id
                and role_nm <> 'Aggregator Document Level'
             ) t1 inner join 
             (
                  select doc_access_id,doc_hdr_id,prncpl_id, role_nm from document_access
                  where doc_hdr_id = r_data.doc_hdr_id
                  and role_nm = 'Aggregator Document Level'
             ) t2 
             on t1.doc_hdr_id = t2.doc_hdr_id and t1.prncpl_id = t2.prncpl_id    
    );
  
  commit;
  
  end loop;
  close c_data;

end;
/
commit
/
alter table document_access enable constraint UQ_DOCUMENT_ACCESS1
/
alter table document_access enable constraint UQ_DOCUMENT_ACCESS2
/
