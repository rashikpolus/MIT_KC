DROP TABLE OSP$NARRATIVE_PDF 
/
CREATE TABLE OSP$NARRATIVE_PDF 
   (PROPOSAL_NUMBER VARCHAR2(8), 
	MODULE_NUMBER NUMBER(3,0), 
	NARRATIVE_PDF BLOB, 
	FILE_NAME VARCHAR2(150), 
	UPDATE_USER VARCHAR2(8), 
	UPDATE_TIMESTAMP DATE , 
	MIME_TYPE VARCHAR2(100));
	commit;
	insert into OSP$NARRATIVE_PDF(PROPOSAL_NUMBER,MODULE_NUMBER,NARRATIVE_PDF,FILE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,MIME_TYPE)
    SELECT to_number(PROPOSAL_NUMBER),MODULE_NUMBER,NARRATIVE_PDF,FILE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,MIME_TYPE FROM OSP$NARRATIVE_PDF@coeus.kuali;
	commit
	/
DECLARE
li_count number;
CURSOR c_attach IS
SELECT n.PROPOSAL_NUMBER,n.MODULE_NUMBER,n.FILE_NAME FROM NARRATIVE n left outer join NARRATIVE_ATTACHMENT na ON  
n.PROPOSAL_NUMBER=na.PROPOSAL_NUMBER AND n.MODULE_NUMBER=na.MODULE_NUMBER  
WHERE na.PROPOSAL_NUMBER IS NULL AND n.FILE_NAME IS NOT NULL;
r_attach c_attach%rowtype;

BEGIN
IF c_attach%ISOPEN THEN
CLOSE c_attach;
END IF;
OPEN c_attach;
LOOP
FETCH c_attach INTO r_attach;
EXIT WHEN c_attach%notfound;

SELECT COUNT(PROPOSAL_NUMBER) INTO li_count FROM NARRATIVE_ATTACHMENT 
WHERE PROPOSAL_NUMBER=r_attach.PROPOSAL_NUMBER AND MODULE_NUMBER=r_attach.MODULE_NUMBER AND FILE_NAME=r_attach.FILE_NAME;

IF li_count=0 THEN

INSERT INTO NARRATIVE_ATTACHMENT (PROPOSAL_NUMBER,MODULE_NUMBER,NARRATIVE_DATA,FILE_NAME,CONTENT_TYPE,UPDATE_USER,UPDATE_TIMESTAMP,VER_NBR,OBJ_ID)
SELECT PROPOSAL_NUMBER,MODULE_NUMBER,NARRATIVE_PDF,FILE_NAME,MIME_TYPE,UPDATE_USER,UPDATE_TIMESTAMP,1,SYS_GUID() FROM OSP$NARRATIVE_PDF
WHERE PROPOSAL_NUMBER=r_attach.PROPOSAL_NUMBER AND MODULE_NUMBER=r_attach.MODULE_NUMBER AND FILE_NAME=r_attach.FILE_NAME;

END IF;

END LOOP;
CLOSE c_attach;
END;
/
commit
/
