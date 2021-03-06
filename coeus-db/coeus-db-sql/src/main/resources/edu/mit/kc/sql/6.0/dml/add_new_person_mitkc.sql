DECLARE
li_seq_entity_id NUMBER(8);
li_seq_entity_afltn_id NUMBER(8);
li_seq_entity_emp_id NUMBER(8);
li_seq_entity_addr_id NUMBER(8);
li_seq_entity_phn_id NUMBER(8);
li_seq_entity_email_id NUMBER(8);
li_seq_entity_nm_id NUMBER(8);
li_seq_entity_visa_id NUMBER(8);
li_seq_prncpl_id NUMBER(15);
li_seq_fdoc_nbr VARCHAR2(14);
li_seq_person_training_id NUMBER(12,0);
ls_ent_typ_cd VARCHAR2(8):='PERSON';
li_ver_nbr NUMBER(8):=1;
ls_actv_ind VARCHAR2(2):='Y';
ls_dflt_ind VARCHAR2(2):='N';
ls_emp_aftn_typ_ind CHAR(2):='N';
ll_last_upd_tmst date := sysdate;
li_count number;
v_code  NUMBER;
v_errm  VARCHAR2(64);
BEGIN

select count(prncpl_id) into li_count from krim_prncpl_t where prncpl_nm = 'mitkc';

if li_count = 0 then

	select KRIM_ENTITY_ID_S.NEXTVAL into li_seq_entity_id from dual;          
    select KRIM_ENTITY_EMP_ID_S.NEXTVAL into li_seq_entity_emp_id from dual; 
    select KRIM_ENTITY_NM_ID_S.NEXTVAL into li_seq_entity_nm_id from dual;
	select KRIM_PRNCPL_ID_S.NEXTVAL into li_seq_prncpl_id from dual;    	
	
    INSERT INTO KRIM_ENTITY_T(ENTITY_ID,OBJ_ID,VER_NBR,ACTV_IND,LAST_UPDT_DT) 
    VALUES( li_seq_entity_id,SYS_GUID(),li_ver_nbr,ls_actv_ind,ll_last_upd_tmst);
	
    begin
      select KREW_DOC_HDR_S.NEXTVAL into li_seq_fdoc_nbr from dual;
      INSERT INTO KRIM_PERSON_DOCUMENT_T(FDOC_NBR,ENTITY_ID,OBJ_ID,VER_NBR,PRNCPL_ID,PRNCPL_NM,PRNCPL_PSWD,UNIV_ID,ACTV_IND)
      VALUES(li_seq_fdoc_nbr,li_seq_entity_id,SYS_GUID(),li_ver_nbr,li_seq_prncpl_id,'mitkc',NULL,NULL,ls_actv_ind);

      INSERT INTO KRIM_PRNCPL_T(PRNCPL_ID,OBJ_ID,VER_NBR,PRNCPL_NM,ENTITY_ID,PRNCPL_PSWD,ACTV_IND,LAST_UPDT_DT)
      VALUES(li_seq_prncpl_id,SYS_GUID(),li_ver_nbr,'mitkc',li_seq_entity_id,NULL,ls_actv_ind,ll_last_upd_tmst);

    exception
    when others then    
    dbms_output.put_line('Error for person_id'||li_seq_prncpl_id||' '||sqlerrm);  
    end;
	
	select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;	
	INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
	VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,'AFLT','UN','Y',ls_actv_ind,ll_last_upd_tmst);				   

	INSERT INTO KRIM_ENTITY_ENT_TYP_T(ENT_TYP_CD,ENTITY_ID,ACTV_IND,OBJ_ID,VER_NBR,LAST_UPDT_DT) 
    VALUES(ls_ent_typ_cd,li_seq_entity_id,ls_actv_ind,SYS_GUID(),li_ver_nbr,ll_last_upd_tmst);   
	  
	  
	BEGIN
	  select KRIM_ENTITY_EMAIL_ID_S.NEXTVAL into li_seq_entity_email_id from dual;
	  INSERT INTO KRIM_ENTITY_EMAIL_T(ENTITY_EMAIL_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,EMAIL_TYP_CD,EMAIL_ADDR,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
	  VALUES(li_seq_entity_email_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,'WRK','mitkc@mit.edu','Y',ls_actv_ind,ll_last_upd_tmst);
	
	EXCEPTION
	WHEN OTHERS THEN 
		v_code := SQLCODE;
		v_errm := SUBSTR(SQLERRM, 1, 64);
		DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
		dbms_output.put_line('Error occoured for KRIM_ENTITY_EMAIL_T  for the person '||li_seq_prncpl_id); 
	END;  
			  
	BEGIN   
	  INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,FIRST_NM,MIDDLE_NM,LAST_NM,SUFFIX_NM,TITLE_NM,DFLT_IND,ACTV_IND,LAST_UPDT_DT,PREFIX_NM,NOTE_MSG,NM_CHNG_DT)  
	  VALUES(li_seq_entity_nm_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,'PRFR','mit',NULL,'kc',NULL,NULL,'Y',ls_actv_ind,ll_last_upd_tmst,NULL,NULL,NULL);

    EXCEPTION
    WHEN OTHERS THEN 
	 v_code := SQLCODE;
	 v_errm := SUBSTR(SQLERRM, 1, 64);
	 DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
     dbms_output.put_line('Error occoured for KRIM_ENTITY_NM_T  for the person '||li_seq_prncpl_id); 
    END; 
		   
	BEGIN
      INSERT INTO KRIM_ENTITY_EMP_INFO_T(ENTITY_EMP_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENTITY_AFLTN_ID,EMP_STAT_CD,EMP_TYP_CD,BASE_SLRY_AMT,PRMRY_IND,ACTV_IND,PRMRY_DEPT_CD,EMP_ID,EMP_REC_ID,LAST_UPDT_DT) 
      VALUES(li_seq_entity_emp_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,li_seq_entity_afltn_id,'A','O',0.00,'Y',ls_actv_ind,'000001',li_seq_prncpl_id,'1',ll_last_upd_tmst);


    EXCEPTION
    WHEN OTHERS THEN 
      v_code := SQLCODE;
	  v_errm := SUBSTR(SQLERRM, 1, 64);
	  DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
      dbms_output.put_line('Error occoured for KRIM_ENTITY_EMP_INFO_T  for the person '||li_seq_prncpl_id); 
    END;
	
	
end if;
	
END;
/
commit
/
INSERT INTO person_inactive_exception(prncpl_id)
select t2.prncpl_id from krim_prncpl_t t2 
where prncpl_nm in ('mitkc')
/
commit
/