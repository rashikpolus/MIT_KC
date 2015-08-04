declare
cursor c_update is
select to_number(PROPOSAL_NUMBER) PROPOSAL_NUMBER,MODULE_NUMBER,MODULE_TITLE from OSP$NARRATIVE@coeus.kuali
where MODULE_TITLE is not null;
r_update c_update%rowtype;

begin
if c_update%isopen then
close c_update;
end if;
open c_update;
loop
fetch c_update into r_update;
exit when c_update%notfound;

update narrative set module_title = r_update.MODULE_TITLE
where proposal_number = r_update.PROPOSAL_NUMBER
and module_number = r_update.MODULE_NUMBER;

end loop;
close c_update;
end;
/
commit
/
declare
cursor c_update is
select to_number(PROPOSAL_NUMBER) PROPOSAL_NUMBER,MODULE_NUMBER,COMMENTS from OSP$NARRATIVE@coeus.kuali
where COMMENTS is not null;
r_update c_update%rowtype;

begin
if c_update%isopen then
close c_update;
end if;
open c_update;
loop
fetch c_update into r_update;
exit when c_update%notfound;

update narrative set comments = r_update.COMMENTS
where proposal_number = r_update.PROPOSAL_NUMBER
and module_number = r_update.MODULE_NUMBER;

end loop;
close c_update;
end;
/
commit
/
