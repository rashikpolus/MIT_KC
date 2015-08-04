declare
li_sample number(3);
li_exp_flag number;
ls_award_number varchar2(12);
pos1 varchar2(1);
pos2 varchar2(1);
pos3 varchar2(1);
finalvalue number(8,3);
ls_first_part VARCHAR2(6);
ls_second_part VARCHAR2(5);
ls_final_awd  VARCHAR2(12);
cursor c_award is
select DISTINCT(awd.AWARD_NUMBER) from AWARD awd
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON awd.AWARD_NUMBER = replace(t.MIT_AWARD_NUMBER,'-','-00') and awd.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER  
where t.FEED_TYPE='N';
r_award c_award%rowtype;
begin 

open c_award;
loop
fetch c_award into r_award;
exit when c_award%notfound;
  begin
  li_exp_flag:=0;
  select to_number(substr(r_award.AWARD_NUMBER,8,3)) into li_sample from dual;
  exception
  when others then
  li_exp_flag:=1;
  end;
  
  if li_exp_flag = 1 then
    select  replace(r_award.AWARD_NUMBER,'-00','-') into ls_award_number from dual;
    select substr(ls_award_number,8,1)  into pos1 from dual;
    select substr(ls_award_number,9,1)  into pos2 from dual;
    select substr(ls_award_number,10,1) into pos3 from dual;
    finalvalue := 1000 + (26*(26*(ASCII(pos1)-65)) + 26*(ASCII(pos2)-65) + (ASCII(pos3)-64));
    finalvalue := finalvalue-1;
    select  substr(r_award.AWARD_NUMBER,1,6) into ls_first_part from dual;
    select  trim(to_char(finalvalue,'00000')) into ls_second_part from dual;
    ls_final_awd := (ls_first_part||'-'||ls_second_part);
    
    INSERT INTO KC_MIG_AWARD_CONV(AWARD_NUMBER,CHANGE_AWARD_NUMBER)
    VALUES(r_award.AWARD_NUMBER,ls_final_awd);
    commit;    
  end if;
end loop;
close c_award;
end;
/