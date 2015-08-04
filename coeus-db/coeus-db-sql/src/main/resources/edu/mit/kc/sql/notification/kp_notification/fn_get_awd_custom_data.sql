create or replace
function fn_get_awd_custom_data(as_award in AWARD_CUSTOM_DATA.AWARD_NUMBER%type,
as_custom custom_attribute.name%type) return number
is
ls_column_value VARCHAR2(2000);
li_return NUMBER:=1;
/*
possible return value
1 :- blank value / No data
2 :- PC
3 :- PCK
*/
begin

		select t3.value into ls_column_value
		   from  award_custom_data t3
		   where t3.award_number = 	as_award
		   and	 t3.sequence_number = (select max(s1.sequence_number) from award_custom_data s1 where s1.award_number = s1.award_number)
		   and   t3.custom_attribute_id = (select id from custom_attribute where name = as_custom);

if    trim(ls_column_value) = 'PC' then
      li_return := 2;
elsif trim(ls_column_value) = 'PCK' then
      li_return := 3;
else
      li_return := 1;
end if;

return li_return;

exception
when others then
return 1;
end fn_get_awd_custom_data;
/