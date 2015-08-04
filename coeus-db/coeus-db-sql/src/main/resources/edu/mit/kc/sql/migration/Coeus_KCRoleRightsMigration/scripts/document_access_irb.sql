alter table document_access disable constraint UQ_DOCUMENT_ACCESS1
/
alter table document_access disable constraint UQ_DOCUMENT_ACCESS2
/ 
declare
li_count number;
begin
  select  count(table_name) into li_count  from user_tables   where table_name = 'OSP$PROTOCOL_USER_ROLES';
  if li_count = 0 then
    execute immediate('	CREATE TABLE OSP$PROTOCOL_USER_ROLES(
	PROTOCOL_NUMBER VARCHAR2(20) ,
	SEQUENCE_NUMBER NUMBER(4,0), 
	ROLE_ID NUMBER(5,0), 
	USER_ID VARCHAR2(8), 
	UPDATE_TIMESTAMP DATE, 
	UPDATE_USER VARCHAR2(8) )');
  end if;
       
end;
/
declare
li_count NUMBER;
begin

   select count(*) into li_count from OSP$PROTOCOL_USER_ROLES;
   if li_count = 0 then    
      INSERT INTO OSP$PROTOCOL_USER_ROLES(
      PROTOCOL_NUMBER,
	  SEQUENCE_NUMBER,
      ROLE_ID,
      USER_ID,
      UPDATE_TIMESTAMP,
      UPDATE_USER
      )
      SELECT PROTOCOL_NUMBER,
	  (SEQUENCE_NUMBER - 1),
      ROLE_ID,
      USER_ID,
      UPDATE_TIMESTAMP,
      UPDATE_USER
      FROM OSP$PROTOCOL_USER_ROLES@coeus.kuali;         

  end if;
   
end;
/
commit
/
CREATE INDEX OSP$PROTOCOL_USER_ROLES_I ON OSP$PROTOCOL_USER_ROLES(PROTOCOL_NUMBER,SEQUENCE_NUMBER,ROLE_ID,USER_ID)
/
delete from DOCUMENT_ACCESS where DOC_HDR_ID IN(SELECT DOCUMENT_NUMBER FROM PROTOCOL t1 inner join OSP$PROTOCOL_USER_ROLES e  on t1.protocol_number = e.protocol_number and t1.sequence_number = e.sequence_number)
/
commit
/
DECLARE 
ls_mbr_id VARCHAR2(40);
ls_role_nm DOCUMENT_ACCESS.ROLE_NM%TYPE;
ls_nmspc_cd krim_role_t.nmspc_cd%type;

CURSOR c_module_role is
	SELECT distinct t1.protocol_number,t1.sequence_number, t1.document_number,lower(e.USER_ID) USER_ID,e.ROLE_ID,r.role_name,e.UPDATE_USER,e.UPDATE_TIMESTAMP
	FROM OSP$PROTOCOL_USER_ROLES e 
	inner join PROTOCOL t1 on t1.protocol_number = e.protocol_number and t1.sequence_number = e.sequence_number
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
	   dbms_output.put_line('PRNCPL_ID is missing for userID '||r_module_role.USER_ID||' and protocol Number '||r_module_role.protocol_number||' and sequence number '||r_module_role.sequence_number);
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
	 dbms_output.put_line('Exception while inserting to DOCUMENT_ACCESS , the error is '||substr(sqlerrm,1,200)||', protocol number '||r_module_role.protocol_number||' and sequence number '||r_module_role.sequence_number);
  END;                         

  if li_commit_count = 1000 then
	li_commit_count := 0;
	commit;
	
  end if;
  
END LOOP;
CLOSE c_module_role;   

END;              
/
alter table document_access enable constraint UQ_DOCUMENT_ACCESS1
/
alter table document_access enable constraint UQ_DOCUMENT_ACCESS2
/
