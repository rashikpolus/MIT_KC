DECLARE
 li_count number;
 li_custom_id number;
BEGIN
      SELECT COUNT(NAME) into li_count  FROM CUSTOM_ATTRIBUTE WHERE NAME='COEUS_AAA_AWARD_NUMBER';

      IF li_count=0 THEN
        
        select SEQ_CUSTOM_ATTRIBUTE.NEXTVAL into li_custom_id from dual;
        
        INSERT INTO CUSTOM_ATTRIBUTE(ID,NAME,LABEL,DATA_TYPE_CODE,DATA_LENGTH,DEFAULT_VALUE,LOOKUP_CLASS,LOOKUP_RETURN,GROUP_NAME,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
        VALUES(li_custom_id,'COEUS_AAA_AWARD_NUMBER','COEUS_AAA_AWARD_NUMBER','1',10,null,null,null,'Other',sysdate,'admin',1,sys_guid());
        
        INSERT INTO CUSTOM_ATTRIBUTE_DOCUMENT(DOCUMENT_TYPE_CODE,CUSTOM_ATTRIBUTE_ID,TYPE_NAME,IS_REQUIRED,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTIVE_FLAG,OBJ_ID)
        VALUES('AWRD',li_custom_id,null,'N',sysdate,'admin',1,'Y',sys_guid());
      END IF;
END;
/
commit
/
DECLARE
li_custom_id number;
li_count NUMBER;
CURSOR c_custom IS
SELECT replace(k.AWARD_NUMBER,'-00','-') AWARD_NUMBER,k.CHANGE_AWARD_NUMBER,a.AWARD_ID,a.SEQUENCE_NUMBER,a.DOCUMENT_NUMBER FROM KC_MIG_AWARD_CONV k 
INNER JOIN AWARD a ON a.AWARD_NUMBER=k.CHANGE_AWARD_NUMBER
ORDER BY a.AWARD_ID;
r_custom c_custom%ROWTYPE;

BEGIN
IF c_custom%ISOPEN THEN
CLOSE c_custom;
END IF;
OPEN c_custom;
LOOP
FETCH c_custom INTO r_custom;
EXIT WHEN c_custom%NOTFOUND;

 
		SELECT ID into li_custom_id  FROM CUSTOM_ATTRIBUTE WHERE NAME='COEUS_AAA_AWARD_NUMBER';
		
		select count(award_custom_data_id) into li_count from AWARD_CUSTOM_DATA 
		where AWARD_ID = r_custom.AWARD_ID		
		and CUSTOM_ATTRIBUTE_ID = li_custom_id;
		
		if li_count = 0 then
		
			INSERT INTO AWARD_CUSTOM_DATA(AWARD_CUSTOM_DATA_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CUSTOM_ATTRIBUTE_ID,VALUE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
			VALUES(SEQ_AWARD_CUSTOM_DATA_ID.NEXTVAL,r_custom.AWARD_ID,r_custom.CHANGE_AWARD_NUMBER,r_custom.SEQUENCE_NUMBER,li_custom_id,r_custom.AWARD_NUMBER,sysdate,'admin',1,sys_guid());

			INSERT INTO CUSTOM_ATTRIBUTE_DOC_VALUE(DOCUMENT_NUMBER,CUSTOM_ATTRIBUTE_ID,VALUE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
			VALUES(r_custom.DOCUMENT_NUMBER,li_custom_id,r_custom.AWARD_NUMBER,sysdate,'admin',1,sys_guid());
			
		end if;	
		
END LOOP;
CLOSE c_custom;
END;
/
commit
/
