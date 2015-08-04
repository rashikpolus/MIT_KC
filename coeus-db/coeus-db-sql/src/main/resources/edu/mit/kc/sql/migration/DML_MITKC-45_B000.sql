update PROPOSAL_IDC_RATE set ON_CAMPUS_FLAG = 'F' Where ON_CAMPUS_FLAG = 'N'
/
update PROPOSAL_IDC_RATE set ON_CAMPUS_FLAG = 'N' Where ON_CAMPUS_FLAG = 'Y'
/

DECLARE
li_seq NUMBER(4,0);
li_ver_nbr NUMBER:=1;
ls_prop_num VARCHAR2(10);
ls_proposal_num VARCHAR2(10);
ls_comment CLOB;
l_tmp LONG;
li_prop_id	NUMBER(22,0);
li_seq_num NUMBER(4,0);
li_sequence NUMBER(4,0);
li_sequence_num NUMBER(4,0);
CURSOR c_prop_comment IS
SELECT IP.PROPOSAL_ID,IP.PROPOSAL_NUMBER,IP.SEQUENCE_NUMBER FROM PROPOSAL IP order by IP.PROPOSAL_NUMBER,IP.SEQUENCE_NUMBER ;
r_prop_comment c_prop_comment%ROWTYPE;

CURSOR c_comment(as_prop_number VARCHAR2,as_sequence NUMBER) IS
select pc.PROPOSAL_NUMBER,pc.COMMENT_CODE,pc.SEQUENCE_NUMBER,pc.COMMENTS,pc.UPDATE_TIMESTAMP,pc.UPDATE_USER 
from OSP$PROPOSAL_COMMENTS@coeus.kuali pc where pc.PROPOSAL_NUMBER=as_prop_number and pc.SEQUENCE_NUMBER in(
select max(IP.SEQUENCE_NUMBER) from OSP$PROPOSAL_COMMENTS@coeus.kuali IP where IP.PROPOSAL_NUMBER=pc.PROPOSAL_NUMBER
and IP.COMMENT_CODE=pc.COMMENT_CODE and IP.SEQUENCE_NUMBER<=as_sequence
);
r_comment c_comment%ROWTYPE;

BEGIN

IF c_prop_comment%ISOPEN THEN
CLOSE c_prop_comment;
END IF;
OPEN c_prop_comment;
LOOP
FETCH c_prop_comment INTO r_prop_comment;
EXIT WHEN c_prop_comment%NOTFOUND;

ls_prop_num:=r_prop_comment.PROPOSAL_NUMBER;
li_seq:=r_prop_comment.SEQUENCE_NUMBER;

--select FN_GET_SEQ(ls_prop_num,li_seq) into li_seq_num from dual;
--SELECT PROPOSAL_ID INTO li_prop_id FROM PROPOSAL WHERE PROPOSAL_NUMBER=ls_prop_num AND SEQUENCE_NUMBER=li_seq;

IF c_comment%ISOPEN THEN
CLOSE c_comment;
END IF;
OPEN c_comment(ls_prop_num,li_seq);
LOOP
FETCH c_comment INTO r_comment;
EXIT WHEN c_comment%NOTFOUND;
ls_proposal_num:=r_comment.PROPOSAL_NUMBER;
li_sequence:=r_comment.SEQUENCE_NUMBER;

begin    
l_tmp:=r_comment.COMMENTS;
SELECT substr( l_tmp, 1, 2000 )  INTO ls_comment FROM DUAL;
exception
when others then
ls_comment:=null;
end;   
-- select FN_GET_KUALI_SEQ(ls_proposal_num,li_sequence) into li_sequence_num from dual;

UPDATE PROPOSAL_COMMENTS
SET COMMENTS=ls_comment
where PROPOSAL_NUMBER=r_comment.PROPOSAL_NUMBER
and SEQUENCE_NUMBER=r_prop_comment.SEQUENCE_NUMBER
and COMMENT_TYPE_CODE=r_comment.COMMENT_CODE;

END LOOP;
CLOSE c_comment;
END LOOP;
CLOSE c_prop_comment;
dbms_output.put_line('Completed PROPOSAL_COMMENTS...');
END;      
/