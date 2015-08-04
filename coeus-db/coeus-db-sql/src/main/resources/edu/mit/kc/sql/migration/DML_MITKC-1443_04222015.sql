declare
cursor c_data is
select distinct ORGANIZATION_ID,QUESTION_ID from OSP$ORGANIZATION_YNQ@coeus.kuali;
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
