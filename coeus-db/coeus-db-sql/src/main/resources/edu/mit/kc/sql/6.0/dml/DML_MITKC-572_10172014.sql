set serveroutput on;
declare
	cursor c_data is
	SELECT question_explanation_id,explanation from question_explanation;
	r_data c_data%rowtype;	
	ls_ynq_exp clob ;
begin
	open c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
	
	 begin
	 
		ls_ynq_exp := r_data.explanation;
		
		select replace(ls_ynq_exp,'<html>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</html>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</b>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<b/>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<strong>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</strong>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<body>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</body>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<p>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</p>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<br>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<br/>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</br>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<li>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</li>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<ul>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</ul>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<u>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</u>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<h1>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</h1>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<h2>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</h2>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<h3>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</h3>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<h4>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</h4>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<h5>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</h5>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'<h6>','') into ls_ynq_exp from dual;
		select replace(ls_ynq_exp,'</h6>','') into ls_ynq_exp from dual;
	
		UPDATE question_explanation SET explanation = ls_ynq_exp
		WHERE question_explanation_id = r_data.question_explanation_id;
	
	exception
	when others then
	dbms_output.put_line('Exception occured while updating question_explanation for question_explanation_id' || r_data.question_explanation_id ||'. Error is '||sqlerrm);
	end;
	
	end loop;
	close c_data;

end;
/
