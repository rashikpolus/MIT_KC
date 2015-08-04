INSERT INTO KRIM_ENTITY_EMAIL_T(ENTITY_EMAIL_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,EMAIL_TYP_CD,EMAIL_ADDR,DFLT_IND,
ACTV_IND,LAST_UPDT_DT)   
SELECT KRIM_ENTITY_EMAIL_ID_S.NEXTVAL,SYS_GUID(),1,t1.ENTITY_ID,'PERSON','WRK',t2.EMAIL_ADDRESS,'Y','Y',t2.UPDATE_TIMESTAMP
from krim_prncpl_t t1
inner join osp$person@coeus.kuali t2 on t1.prncpl_id = t2.person_id
where t1.entity_id not in (select entity_id from krim_entity_email_t)
and t2.EMAIL_ADDRESS is not null
/
INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,FIRST_NM,MIDDLE_NM,LAST_NM,SUFFIX_NM,TITLE_NM,DFLT_IND,
ACTV_IND,LAST_UPDT_DT,PREFIX_NM,NOTE_MSG,NM_CHNG_DT)
select KRIM_ENTITY_NM_ID_S.NEXTVAL,SYS_GUID(),1,t1.ENTITY_ID,'PRFR',t2.FIRST_NAME ,t2.MIDDLE_NAME,t2.LAST_NAME,NULL,NULL,'Y','Y',SYSDATE,NULL,NULL,NULL
from krim_prncpl_t t1
inner join osp$person@coeus.kuali t2 on t1.prncpl_id = t2.person_id
where t1.entity_id not in (select entity_id from KRIM_ENTITY_NM_T)
and ( t2.MIDDLE_NAME is not null OR t2.FIRST_NAME is not null OR t2.LAST_NAME is not null)
/
declare

  ls_actv_ind VARCHAR2(2):='Y';
  ls_dflt_ind VARCHAR2(2):='N';
  ls_phone_number varchar2(20);
  
cursor c_phone is 
  select t1.prncpl_id,t1.entity_id,t2.fax_number,t2.pager_number,t2.mobile_phone_number,t2.office_phone,
  t2.secondry_office_phone,t2.update_timestamp
  from krim_prncpl_t t1
  inner join osp$person@coeus.kuali t2 on t1.prncpl_id = t2.person_id
  where t1.entity_id not in (select entity_id from KRIM_ENTITY_PHONE_T)
  and   ( t2.fax_number is not null  or t2.pager_number is not null or
          t2.mobile_phone_number is not null or t2.office_phone is not null or t2.secondry_office_phone is not null
        );
  r_phone c_phone%rowtype;
begin
  
  open c_phone;
  loop
  fetch c_phone into r_phone;
  exit when c_phone%notfound;
    
    begin
      ls_dflt_ind := 'N';
  
      if    r_phone.office_phone is not null then
              ls_dflt_ind := 'Y';
              select replace(translate(r_phone.office_phone,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;
              select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) 
              into ls_phone_number from dual;          
              INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,
              PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
              VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1, r_phone.entity_id,'PERSON','WRK',ls_phone_number,
              NULL,NULL,ls_dflt_ind,ls_actv_ind,r_phone.UPDATE_TIMESTAMP);  
            
      elsif  r_phone.secondry_office_phone is not null then
            if ls_dflt_ind = 'N' then
              ls_dflt_ind := 'Y';
            end if;
            select replace(translate(r_phone.secondry_office_phone,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;
            select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) 
            into ls_phone_number from dual;          
            INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,
            PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
            VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1, r_phone.entity_id,'PERSON','WRK',ls_phone_number,
            NULL,NULL,ls_dflt_ind,ls_actv_ind,r_phone.UPDATE_TIMESTAMP);  
      
      elsif  r_phone.mobile_phone_number is not null then
            if ls_dflt_ind = 'N' then
              ls_dflt_ind := 'Y';
            end if;
            select replace(translate(r_phone.mobile_phone_number,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;
            select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) 
            into ls_phone_number from dual;          
            INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,
            PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
            VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1, r_phone.entity_id,'PERSON','MBL',ls_phone_number,
            NULL,NULL,ls_dflt_ind,ls_actv_ind,r_phone.UPDATE_TIMESTAMP);
            
            
      elsif  r_phone.pager_number is not null then
           if ls_dflt_ind = 'N' then
              ls_dflt_ind := 'Y';
           end if;
          select replace(translate(r_phone.pager_number,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;
          select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) 
          into ls_phone_number from dual;          
          INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,
          PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
          VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1, r_phone.entity_id,'PERSON','PGR',ls_phone_number,
          NULL,NULL,ls_dflt_ind,ls_actv_ind,r_phone.UPDATE_TIMESTAMP);
            
            
      elsif  r_phone.fax_number is not null then
            if ls_dflt_ind = 'N' then
              ls_dflt_ind := 'Y';
            end if;
            select replace(translate(r_phone.fax_number,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;
            select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) 
            into ls_phone_number from dual;          
            INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,
            PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
            VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1, r_phone.entity_id,'PERSON','FAX',ls_phone_number,
            NULL,NULL,ls_dflt_ind,ls_actv_ind,r_phone.UPDATE_TIMESTAMP);
       
       
      end if;
  exception
  when others then
  dbms_output.put_line('Error occoured in KRIM_ENTITY_PHONE_T, Prncpl ID = '||r_phone.prncpl_id||'. Exception is '|| sqlerrm);
  end;
  
  end loop;
  close c_phone;
   
  
end;
/ 
INSERT INTO KRIM_ENTITY_ADDR_T(ENTITY_ADDR_ID,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,
ADDR_TYP_CD,ADDR_LINE_1,ADDR_LINE_2,ADDR_LINE_3,CITY,STATE_PVC_CD,POSTAL_CD,LAST_UPDT_DT,ATTN_LINE,ADDR_FMT,MOD_DT,VALID_DT,
VALID_IND,NOTE_MSG) 
SELECT KRIM_ENTITY_ADDR_ID_S.NEXTVAL,t3.postal_cntry_cd,'Y','Y',SYS_GUID(),1,t1.entity_id,'PERSON','WRK',
substrb(t2.address_line_1,1,45),substrb(t2.address_line_2,1,45),substrb(t2.address_line_3,1,45),t2.city,
t2.state,t2.postal_code,t2.update_timestamp,null,null,t2.update_timestamp,null,null,null
from krim_prncpl_t t1
inner join osp$person@coeus.kuali t2 on t1.prncpl_id = t2.person_id
left outer join KRLC_CNTRY_T t3 on upper(t2.COUNTRY_CODE) = upper(t3.ALT_POSTAL_CNTRY_CD)  
where t1.entity_id not in (select entity_id from KRIM_ENTITY_ADDR_T)
and   ( t2.address_line_1 is not null  or t2.address_line_2 is not null or
        t2.address_line_3 is not null or t2.city is not null or
        t2.state is not null or t2.postal_code is not null
       )
/
