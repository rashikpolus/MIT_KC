declare
	li_count number;
begin
     select count(*) into li_count from user_tables where table_name='OSP$PROTOCOL_RESEARCH_AREAS';
     if li_count=0 then
      execute immediate('CREATE TABLE OSP$PROTOCOL_RESEARCH_AREAS
      (	PROTOCOL_NUMBER VARCHAR2(20), 
      SEQUENCE_NUMBER NUMBER(4,0), 
      RESEARCH_AREA_CODE VARCHAR2(8), 
      UPDATE_TIMESTAMP DATE, 
      UPDATE_USER VARCHAR2(8)
      )');
	    commit;

     end if;
end;
/
declare
	li_count number;
begin
	select count(PROTOCOL_NUMBER) into li_count from OSP$PROTOCOL_RESEARCH_AREAS;
	if li_count = 0 then  

		INSERT INTO OSP$PROTOCOL_RESEARCH_AREAS(
        PROTOCOL_NUMBER,
        SEQUENCE_NUMBER,
        RESEARCH_AREA_CODE,
        UPDATE_TIMESTAMP,
        UPDATE_USER
		)
  SELECT  PROTOCOL_NUMBER,
        (SEQUENCE_NUMBER - 1),
        RESEARCH_AREA_CODE,
        UPDATE_TIMESTAMP,
        UPDATE_USER
  FROM  OSP$PROTOCOL_RESEARCH_AREAS@coeus.kuali;    
 
	end if;
		
end;
/
truncate table PROTOCOL_RESEARCH_AREAS
/
declare
cursor c_irb is
select distinct t1.protocol_id,t1.protocol_number,t1.sequence_number 
from protocol t1 inner join osp$protocol_research_areas t2 on t1.protocol_number = t2.protocol_number
order by t1.protocol_number,t1.sequence_number;
r_irb c_irb%rowtype;

begin
  open c_irb;
  loop
  fetch c_irb into r_irb;
  exit when c_irb%notfound;
    INSERT INTO PROTOCOL_RESEARCH_AREAS(ID,PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,RESEARCH_AREA_CODE,UPDATE_TIMESTAMP,
    UPDATE_USER,VER_NBR,OBJ_ID)
    SELECT SEQ_PROTOCOL_RESEARCH_AREAS_ID.NEXTVAL,r_irb.protocol_id,r_irb.PROTOCOL_NUMBER,r_irb.SEQUENCE_NUMBER,
    t1.RESEARCH_AREA_CODE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,1,SYS_GUID()
    FROM OSP$PROTOCOL_RESEARCH_AREAS t1
    WHERE t1.PROTOCOL_NUMBER = r_irb.protocol_number
    AND   t1.SEQUENCE_NUMBER = ( SELECT MAX(t2.SEQUENCE_NUMBER)  FROM OSP$PROTOCOL_RESEARCH_AREAS t2
                                 WHERE t2.PROTOCOL_NUMBER = t1.PROTOCOL_NUMBER
                                 AND t2.sequence_number <= r_irb.SEQUENCE_NUMBER);
    
  end loop;
  close c_irb;
  
end;
/
commit
/