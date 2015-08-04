DECLARE
li_ver_nbr NUMBER(8):=1;
li_prop_pers_unit_id NUMBER(22);
li_prop_pers_id NUMBER(22);
ls_person_id VARCHAR2(40);
li_indicator_count NUMBER;

li_mit_seq_num NUMBER(4,0);
li_kua_seq_num NUMBER(4,0);
li_count number;
CURSOR c_kp_unit_main IS
SELECT PROPOSAL_NUMBER,SEQUENCE_NUMBER FROM PROPOSAL ORDER BY PROPOSAL_NUMBER,SEQUENCE_NUMBER;
r_kp_unit_main c_kp_unit_main%ROWTYPE;

CURSOR c_pers_units(as_mit varchar2,as_seq number) IS
SELECT PROPOSAL_NUMBER,as_seq SEQUENCE_NUMBER,PERSON_ID,UNIT_NUMBER,'N' LEAD_UNIT_FLAG ,UPDATE_TIMESTAMP,UPDATE_USER,2 INV_FLAG FROM OSP$PROPOSAL_KEY_PERSONS_UNITS@coeus.kuali
where PROPOSAL_NUMBER=as_mit and SEQUENCE_NUMBER =(
select max(aw.sequence_number) from OSP$PROPOSAL_KEY_PERSONS_UNITS@coeus.kuali aw where aw.PROPOSAL_NUMBER=OSP$PROPOSAL_KEY_PERSONS_UNITS.PROPOSAL_NUMBER 
and aw.sequence_number<=as_seq); 
r_pers_units c_pers_units%ROWTYPE;

BEGIN

IF c_kp_unit_main%ISOPEN THEN
CLOSE c_kp_unit_main;
END IF;
OPEN c_kp_unit_main;
LOOP
FETCH c_kp_unit_main INTO r_kp_unit_main;
EXIT WHEN c_kp_unit_main%NOTFOUND;

li_mit_seq_num:=r_kp_unit_main.SEQUENCE_NUMBER;

select COUNT(proposal_number) into li_indicator_count from osp$proposal@coeus.kuali where PROPOSAL_NUMBER=r_kp_unit_main.PROPOSAL_NUMBER and sequence_number = li_mit_seq_num and KEY_PERSON_INDICATOR IN ('P0','P1');

if li_indicator_count > 0 then

IF c_pers_units%ISOPEN THEN
CLOSE c_pers_units;
END IF;
OPEN c_pers_units(r_kp_unit_main.PROPOSAL_NUMBER,li_mit_seq_num);
LOOP
FETCH c_pers_units INTO r_pers_units;
EXIT WHEN c_pers_units%NOTFOUND;

SELECT SEQ_PROPOSAL_PROPOSAL_ID.NEXTVAL INTO li_prop_pers_unit_id FROM DUAL;
--select FN_GET_KUALI_SEQ(r_pers_units.PROPOSAL_NUMBER,r_pers_units.SEQUENCE_NUMBER) into li_kua_seq_num from dual;
ls_person_id:=r_pers_units.PERSON_ID;     

BEGIN
IF   r_pers_units.INV_FLAG=1 THEN         
SELECT PROPOSAL_PERSON_ID INTO li_prop_pers_id FROM PROPOSAL_PERSONS WHERE PROPOSAL_NUMBER=r_pers_units.PROPOSAL_NUMBER AND
SEQUENCE_NUMBER=r_kp_unit_main.SEQUENCE_NUMBER AND(PERSON_ID=to_char(r_pers_units.PERSON_ID) OR ROLODEX_ID=to_number(r_pers_units.PERSON_ID)) AND contact_role_code IN ('PI','COI');

ELSE
SELECT PROPOSAL_PERSON_ID INTO li_prop_pers_id FROM PROPOSAL_PERSONS WHERE PROPOSAL_NUMBER=r_pers_units.PROPOSAL_NUMBER AND
SEQUENCE_NUMBER=r_kp_unit_main.SEQUENCE_NUMBER AND(PERSON_ID=to_char(r_pers_units.PERSON_ID) OR ROLODEX_ID=to_number(r_pers_units.PERSON_ID))  AND contact_role_code IN ('KP');

END IF;

select count(PROPOSAL_PERSON_UNIT_ID) into li_count where PROPOSAL_PERSON_ID=li_prop_pers_id and UNIT_NUMBER=r_pers_units.UNIT_NUMBER AND LEAD_UNIT_FLAG='N';

if li_count=0 then

INSERT INTO PROPOSAL_PERSON_UNITS(PROPOSAL_PERSON_UNIT_ID,PROPOSAL_PERSON_ID,UNIT_NUMBER,LEAD_UNIT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_prop_pers_unit_id,li_prop_pers_id,r_pers_units.UNIT_NUMBER,r_pers_units.LEAD_UNIT_FLAG,r_pers_units.UPDATE_TIMESTAMP,r_pers_units.UPDATE_USER,li_ver_nbr,SYS_GUID());

end if;

EXCEPTION
WHEN OTHERS THEN 
dbms_output.put_line('ERROR IN PROPOSAL_PERSON_UNITS,PROPOSAL_NUMBER: '||r_pers_units.PROPOSAL_NUMBER||'- SEQUENCE_NUMBER= '||r_pers_units.SEQUENCE_NUMBER||',  '||r_pers_units.PERSON_ID||' ,  '||r_pers_units.INV_FLAG||sqlerrm);
END;

END LOOP;
CLOSE c_pers_units;
end if;

END LOOP;
CLOSE c_kp_unit_main;
dbms_output.put_line('Completed PROPOSAL_PERSON_UNITS(for KeyPerson)!!!');
END;
/
