select ' Started AWARD_HIERARCHY script ' from dual
/
DECLARE
li_ver_nbr NUMBER(8):=1;
ls_active CHAR(1 ):='Y';
li_award_hierarchy_id  NUMBER(22);
ls_root_awd varchar2(12);
ls_parent_awd varchar2(12);
ls_origin_awd varchar2(12);
ls_mit_awd varchar2(12);
ls_min_awd varchar2(12);
li_commit_count number:=0;
CURSOR c_hierarchy IS
SELECT a.ROOT_MIT_AWARD_NUMBER,a.MIT_AWARD_NUMBER,a.PARENT_MIT_AWARD_NUMBER,a.UPDATE_TIMESTAMP,a.UPDATE_USER FROM OSP$AWARD_HIERARCHY a
inner join TEMP_TAB_TO_SYNC_AWARD ts on a.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER and ts.FEED_TYPE='N';
r_hierarchy c_hierarchy%ROWTYPE;

BEGIN
IF c_hierarchy%ISOPEN THEN 
CLOSE c_hierarchy;
END IF;
OPEN c_hierarchy;
LOOP
FETCH c_hierarchy  INTO r_hierarchy;
EXIT WHEN c_hierarchy%notfound;

begin
ls_root_awd:=r_hierarchy.ROOT_MIT_AWARD_NUMBER;
ls_parent_awd:=r_hierarchy.PARENT_MIT_AWARD_NUMBER;
ls_mit_awd:=r_hierarchy.MIT_AWARD_NUMBER;

if     ls_mit_awd=ls_root_awd then
   ls_origin_awd:=ls_root_awd;
else  
	select min(MIT_AWARD_NUMBER) into ls_min_awd from OSP$AWARD_HIERARCHY where PARENT_MIT_AWARD_NUMBER =ls_parent_awd;   

   if ls_parent_awd=ls_min_awd then
	  ls_origin_awd:=ls_min_awd;
   else
	  ls_origin_awd:=ls_root_awd;
   end if;    
end if;
exception when others then
dbms_output.put_line('error was occoured for '||ls_mit_awd||'  .'||sqlerrm);

end;
SELECT replace(ls_parent_awd,'-','-00') INTO ls_parent_awd FROM DUAL;
SELECT replace(ls_mit_awd,'-','-00') INTO ls_mit_awd FROM DUAL;
SELECT replace(ls_root_awd,'-','-00') INTO ls_root_awd FROM DUAL;
SELECT replace(ls_origin_awd,'-','-00') INTO ls_origin_awd FROM DUAL;
BEGIN
SELECT SEQUENCE_AWARD_ID.NEXTVAL INTO li_award_hierarchy_id FROM DUAL;
INSERT INTO AWARD_HIERARCHY(AWARD_HIERARCHY_ID,ROOT_AWARD_NUMBER,AWARD_NUMBER,PARENT_AWARD_NUMBER,ORIGINATING_AWARD_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,ACTIVE)
VALUES(li_award_hierarchy_id,ls_root_awd,ls_mit_awd,ls_parent_awd,ls_origin_awd,r_hierarchy.UPDATE_TIMESTAMP,r_hierarchy.UPDATE_USER,li_ver_nbr,SYS_GUID(),ls_active);
li_commit_count:= li_commit_count + 1;
if li_commit_count =1000 then
li_commit_count:=0;
commit;
end if;

EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('ERROR IN AWARD_HIERARCHY,AWARD_NUMBER:'||ls_mit_awd||'-'||sqlerrm);
END;
END LOOP;
CLOSE c_hierarchy;
dbms_output.put_line('Completed AWARD_HIERARCHY!!!');
END;
/
select ' Ended AWARD_HIERARCHY script ' from dual
/