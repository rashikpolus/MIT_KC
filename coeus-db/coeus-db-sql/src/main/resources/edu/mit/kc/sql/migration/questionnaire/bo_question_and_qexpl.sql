select ' Start time of QUESTION MODULE  is '|| localtimestamp from dual
/
DECLARE
ls_seq_status VARCHAR2(2):='C';
ls_valid_answer VARCHAR2(20);
li_quest_typ_id  NUMBER(12,0);
li_quest_ref_id NUMBER(12,0);
li_quest_id NUMBER(6,0);
ls_lookup_class  VARCHAR2(100);
ls_lookup_gui VARCHAR2(50);
ls_loopup_return VARCHAR2(30);
ls_lookup_name VARCHAR2(50);
li_ver_nbr number:=1;
li_questionnaire number;
li_condition VARCHAR2(50);
li_quest_expl_id number;
li_count_qst number;
li_count_qst_expl number;

CURSOR c_qid is
select coe.* from osp$question@coeus.kuali coe;
r_qid c_qid%ROWTYPE;

CURSOR c_expl IS
SELECT * FROM TEMP_QUESTION_EXPLANATION;
r_expl c_expl%ROWTYPE;

BEGIN

IF c_qid%ISOPEN THEN
CLOSE c_qid;
END IF;
OPEN c_qid;
LOOP
FETCH c_qid INTO r_qid;
EXIT WHEN c_qid%NOTFOUND;
SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_quest_ref_id FROM DUAL; 
li_quest_id:=r_qid.QUESTION_ID;
ls_valid_answer:=UPPER(TRIM(r_qid.VALID_ANSWER));

IF ls_valid_answer='YN' THEN
li_quest_typ_id:=1;
ELSIF  ls_valid_answer='YNX' THEN
li_quest_typ_id:=2;
ELSIF  ls_valid_answer='SEARCH' THEN
li_quest_typ_id:=6;
ELSIF  ls_valid_answer='TEXT' THEN
if    UPPER(TRIM(r_qid.ANSWER_DATA_TYPE))='DATE' then
li_quest_typ_id:=4;
elsif UPPER(TRIM(r_qid.ANSWER_DATA_TYPE))='NUMBER' then  
li_quest_typ_id:=3;
else
li_quest_typ_id:=5; 
end if;

END IF;

ls_lookup_gui:=UPPER(TRIM(r_qid.LOOKUP_GUI));
ls_lookup_name:=TRIM(r_qid.LOOKUP_NAME);

IF ls_lookup_gui ='VALUELIST' THEN
ls_lookup_class:='org.kuali.kra.bo.ArgValueLookup';
ls_loopup_return:=ls_lookup_name;
	/*
	 IF    ls_lookup_name='Graduate Level Degree' THEN
		   ls_loopup_return:='GraduateLevelDegree';
	 ELSIF ls_lookup_name='Field of Training-Sub Category' THEN
		   ls_loopup_return:='Field of Training-Sub Category';
	 ELSIF ls_lookup_name ='Field of Training-Broad' THEN
		   ls_loopup_return:='Field of Training-Broad';
	 ELSIF ls_lookup_name='Kirschstein-NRSA support level' THEN
		   ls_loopup_return:='Kirschstein-NRSA support level';
	 ELSIF ls_lookup_name='Kirschstein-NRSA Award TYPE' THEN
		   ls_loopup_return:='Kirschstein-NRSA Award TYPE';  
	 ELSIF ls_lookup_name='Academic Appointment Period' THEN
		   ls_loopup_return:='Academic Appointment Period'; 
	ELSIF  ls_lookup_name='Agency_US GOV' THEN
		   ls_loopup_return:='Agency_US GOV'; 
	ELSIF  ls_lookup_name='PROPOSAL_SUPPORT_lIST' THEN
		   ls_loopup_return:='PROPOSAL_SUPPORT_lIST'; 
	ELSIF  ls_lookup_name='STATE_EO_12372' THEN
		   ls_loopup_return:='STATE_EO_12372'; 
	ELSE
		   ls_loopup_return:=NULL; 
	END IF;   
	*/		
ELSIF  ls_lookup_gui='CODETABLE' THEN    
IF    ls_lookup_name='STATE' THEN
   ls_lookup_class:='org.kuali.rice.kns.bo.StateImpl';
   ls_loopup_return:='postalStateName';
ELSIF ls_lookup_name='COUNTRY' THEN
   ls_lookup_class:='org.kuali.rice.kns.bo.CountryImpl';
   ls_loopup_return:='postalCountryName';     
ELSE
   ls_lookup_class:=NULL;
   ls_loopup_return:=NULL;  
END IF;
ELSIF  ls_lookup_gui='PERSONSEARCH' THEN     
ls_lookup_class:='org.kuali.kra.bo.KcPerson';
ls_loopup_return:='personId';			 
ELSIF  ls_lookup_gui='ROLODEXSEARCH' THEN     
ls_lookup_class:='org.kuali.kra.bo.NonOrganizationalRolodex';
ls_loopup_return:='rolodexId';
ELSIF  ls_lookup_gui='ORGANIZATIONSEARCH' THEN     
ls_lookup_class:='org.kuali.kra.bo.Organization';
ls_loopup_return:='organizationName';       
ELSE
ls_lookup_class:=NULL;
ls_loopup_return:=NULL;           
END IF;      

INSERT INTO QUESTION(QUESTION_REF_ID,QUESTION_ID,SEQUENCE_NUMBER,SEQUENCE_STATUS,QUESTION,STATUS,GROUP_TYPE_CODE,QUESTION_TYPE_ID,LOOKUP_CLASS,LOOKUP_RETURN,DISPLAYED_ANSWERS,MAX_ANSWERS,ANSWER_MAX_LENGTH,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_quest_ref_id,li_quest_id,r_qid.VERSION_NUMBER,ls_seq_status,r_qid.QUESTION,r_qid.STATUS,r_qid.GROUP_TYPE_CODE,li_quest_typ_id,ls_lookup_class,ls_loopup_return,null,r_qid.MAX_ANSWERS,r_qid.ANSWER_MAX_LENGTH,r_qid.UPDATE_TIMESTAMP,r_qid.UPDATE_USER,li_ver_nbr,SYS_GUID());

END LOOP;
CLOSE c_qid;
------questionnaire explanation----------------- 

IF c_expl%ISOPEN THEN
CLOSE c_expl;
END IF;

OPEN c_expl;
LOOP
FETCH c_expl INTO r_expl;
EXIT WHEN c_expl%NOTFOUND;

SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_quest_expl_id FROM DUAL;    

SELECT QUESTION_REF_ID INTO li_quest_ref_id FROM QUESTION WHERE QUESTION_ID=r_expl.QUESTION_ID
AND SEQUENCE_NUMBER=(SELECT MAX(q.SEQUENCE_NUMBER) FROM QUESTION q WHERE q.QUESTION_ID=r_expl.QUESTION_ID);

INSERT INTO QUESTION_EXPLANATION(QUESTION_EXPLANATION_ID,QUESTION_REF_ID_FK,EXPLANATION_TYPE,EXPLANATION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_quest_expl_id,li_quest_ref_id,r_expl.EXPLANATION_TYPE,r_expl.EXPLANATION,r_expl.UPDATE_TIMESTAMP,r_expl.UPDATE_USER,li_ver_nbr,SYS_GUID());

END LOOP;
CLOSE c_expl;          
dbms_output.put_line(CHR(10));
dbms_output.put_line('Successfully inserted into  QUESTION,QUESTION_EXPLANATION ');

select count(QUESTION_REF_ID) into li_count_qst from QUESTION;
select count(QUESTION_EXPLANATION_ID) into li_count_qst_expl from QUESTION_EXPLANATION;
dbms_output.put_line('------------------Row Counts----------------');
dbms_output.put_line('QUESTION : '||li_count_qst);
dbms_output.put_line('QUESTION_EXPLANATION : '||li_count_qst_expl);    
END;
/
commit
/