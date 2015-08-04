INSERT INTO YNQ(QUESTION_ID,DESCRIPTION,QUESTION_TYPE,NO_OF_ANSWERS,EXPLANATION_REQUIRED_FOR,DATE_REQUIRED_FOR,STATUS,EFFECTIVE_DATE,GROUP_NAME,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,SORT_ID)
select coe.QUESTION_ID,coe.DESCRIPTION,coe.QUESTION_TYPE,coe.NO_OF_ANSWERS,coe.EXPLANATION_REQUIRED_FOR,coe.DATE_REQUIRED_FOR,coe.STATUS,coe.EFFECTIVE_DATE,decode(coe.QUESTION_TYPE,'O','Organization',nvl(coe.GROUP_NAME,'Proposal Questions')),coe.UPDATE_TIMESTAMP,coe.UPDATE_USER,1,SYS_GUID(),NULL from osp$ynq@coeus.kuali coe where not exists(select kua.QUESTION_ID from ynq kua where
kua.QUESTION_ID=coe.QUESTION_ID)
/
declare
l_tmp long;
ll_expl clob;
li_count_ynq_expl number;
CURSOR c_ynq IS
select coe.QUESTION_ID,coe.EXPLANATION_TYPE,coe.EXPLANATION,coe.UPDATE_TIMESTAMP,coe.UPDATE_USER,1,SYS_GUID(),NULL from OSP$YNQ_EXPLANATION@coeus.kuali coe where not exists(select kua.QUESTION_ID from YNQ_EXPLANATION kua where
kua.QUESTION_ID=coe.QUESTION_ID AND
kua.EXPLANATION_TYPE=coe.EXPLANATION_TYPE);
r_ynq c_ynq%ROWTYPE;


BEGIN
IF c_ynq%ISOPEN THEN
CLOSE c_ynq;
END IF;

OPEN c_ynq;
LOOP
FETCH c_ynq INTO r_ynq;
EXIT WHEN c_ynq%NOTFOUND;
begin 
l_tmp:= r_ynq.EXPLANATION;
SELECT to_char(l_tmp)  INTO ll_expl FROM DUAL;
exception
when others then
ll_expl:=null;
end;

insert into YNQ_EXPLANATION(QUESTION_ID,EXPLANATION_TYPE,EXPLANATION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)   
values (r_ynq.QUESTION_ID,r_ynq.EXPLANATION_TYPE,ll_expl,r_ynq.UPDATE_TIMESTAMP,r_ynq.UPDATE_USER,1,sys_guid()); 
END LOOP;
CLOSE c_ynq;
END;
/
declare
l_tmp long;
ls_expl varchar2(2000);
li_count_org_ynq number;
CURSOR c_org IS
select o.ORGANIZATION_ID,o.QUESTION_ID,o.ANSWER,o.EXPLANATION,o.REVIEW_DATE,o.UPDATE_TIMESTAMP,o.UPDATE_USER,1,SYS_GUID() from OSP$ORGANIZATION_YNQ@coeus.kuali o
left outer join ORGANIZATION_YNQ y on o.ORGANIZATION_ID = y.ORGANIZATION_ID and o.QUESTION_ID = y.QUESTION_ID
where y.ORGANIZATION_ID is null
and o.QUESTION_ID in('KC2','KC3','KC4','KC1');
r_org c_org%ROWTYPE;

BEGIN
IF c_org%ISOPEN THEN
CLOSE c_org;
END IF;
OPEN c_org;
LOOP
FETCH c_org INTO r_org;
EXIT WHEN c_org%NOTFOUND;
begin    
l_tmp:=r_org.EXPLANATION;
SELECT substr( l_tmp, 1, 2000 )  INTO ls_expl FROM DUAL;
exception
when others then
ls_expl:=null;
end;
insert into ORGANIZATION_YNQ(ORGANIZATION_ID,QUESTION_ID,ANSWER,EXPLANATION,REVIEW_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
values (r_org.ORGANIZATION_ID,r_org.QUESTION_ID,r_org.ANSWER,ls_expl,r_org.REVIEW_DATE,r_org.UPDATE_TIMESTAMP,r_org.UPDATE_USER,1,sys_guid()); 
END LOOP;
CLOSE c_org;
EXCEPTION WHEN OTHERS THEN
dbms_output.put_line('Exception occoured '||sqlerrm);
END; 
/
declare
cursor c_data is
select distinct ORGANIZATION_ID,QUESTION_ID from OSP$ORGANIZATION_YNQ@coeus.kuali
where QUESTION_ID in('KC2','KC3','KC4','KC1');
r_data c_data%rowtype;

begin
    if 	c_data%isopen then
	    close c_data;
    end if;
	open c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
		begin
		    
            insert into ORGANIZATION_YNQ(ORGANIZATION_ID,
			                             QUESTION_ID,
										 ANSWER,
										 EXPLANATION,
										 REVIEW_DATE,
										 UPDATE_TIMESTAMP,
										 UPDATE_USER,
										 VER_NBR,
										 OBJ_ID)
			                      select r_data.ORGANIZATION_ID,
								         t1.QUESTION_ID,
										 'X',
										 null,
										 null,
										 sysdate,
										 user,
										 1,
										 sys_guid()
			                        from YNQ t1 
			                        left outer join ORGANIZATION_YNQ t2 on t2.ORGANIZATION_ID = r_data.ORGANIZATION_ID and t1.QUESTION_ID = t2.QUESTION_ID
			                        where t2.QUESTION_ID is null
			                        and UPPER(t1.QUESTION_TYPE) = UPPER('O')
			                        and t1.STATUS = 'A'
			                        and upper(t1.GROUP_NAME) = upper('Organization');
		exception
		when others then
			dbms_output.put_line('Exception occurred Missing YNQ '||sqlerrm);
		end;	
		
	end loop;
	close c_data;
	

end; 
/
commit
/
