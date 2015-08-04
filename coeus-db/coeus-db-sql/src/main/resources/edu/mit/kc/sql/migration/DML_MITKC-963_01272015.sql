DECLARE
li_ver_nbr NUMBER(8):=1;
li_proto_person_id NUMBER(12,0);
ls_proto_num VARCHAR2(20 BYTE);
li_sequence NUMBER(4,0);
li_seq NUMBER(4,0);
ls_person_id VARCHAR2(40);
li_rolodex_id NUMBER(12,0);
ls_full_name VARCHAR2(90);
li_sequence_num NUMBER(4,0);
li_submission_type NUMBER(3,0);
li_submission_status NUMBER(3,0);
ls_proto VARCHAR2(10);
ls_number VARCHAR2(20):=null;
ls_test_number VARCHAR2(20);
li_flag NUMBER;
li_protocol_id NUMBER(12,0);
li_rolodex_count NUMBER;
ls_protocol_num VARCHAR2(20);
li_seq_num NUMBER(4);
li_mit_seq_num NUMBER(4,0);

CURSOR c_proto is
select PROTOCOL_NUMBER,SEQUENCE_NUMBER FROM PROTOCOL ORDER BY PROTOCOL_NUMBER,SEQUENCE_NUMBER;
r_proto c_proto%ROWTYPE;

CURSOR c_inv(as_protocol_number VARCHAR2,as_sequence NUMBER) IS
SELECT inv.PROTOCOL_NUMBER,inv.SEQUENCE_NUMBER,inv.PERSON_ID,DECODE(inv.CORRESPONDENT_TYPE_CODE,1,'CA',2,'CRC') PROTOCOL_PERSON_ROLE_ID FROM OSP$PROTOCOL_CORRESPONDENTS@coeus.kuali inv
WHERE PROTOCOL_NUMBER=as_protocol_number AND SEQUENCE_NUMBER =(SELECT MAX(Pi.SEQUENCE_NUMBER) FROM OSP$PROTOCOL_CORRESPONDENTS@coeus.kuali pi where pi.PROTOCOL_NUMBER=inv.PROTOCOL_NUMBER and Pi.SEQUENCE_NUMBER<=as_sequence);
r_inv c_inv%rowtype;

BEGIN
IF c_proto%ISOPEN THEN
CLOSE c_proto;
END IF;
OPEN c_proto;
LOOP
FETCH c_proto INTO r_proto;
EXIT WHEN c_proto%NOTFOUND;
ls_protocol_num:=r_proto.PROTOCOL_NUMBER;
li_seq:=r_proto.SEQUENCE_NUMBER;
select FN_GET_SEQ(ls_protocol_num,li_seq) into li_mit_seq_num from dual;

IF c_inv%ISOPEN THEN
CLOSE c_inv;
END IF;
OPEN c_inv(ls_protocol_num,li_mit_seq_num);
LOOP
FETCH c_inv INTO r_inv; 
EXIT WHEN c_inv%NOTFOUND;




UPDATE PROTOCOL_PERSONS
SET PROTOCOL_PERSON_ROLE_ID=r_inv.PROTOCOL_PERSON_ROLE_ID
WHERE PROTOCOL_NUMBER=ls_protocol_num
AND SEQUENCE_NUMBER=li_seq
AND PERSON_ID=r_inv.PERSON_ID
AND PROTOCOL_PERSON_ROLE_ID='CRC';

END LOOP;
CLOSE c_inv;
END LOOP;
CLOSE c_proto;
END;
/
commit
/
