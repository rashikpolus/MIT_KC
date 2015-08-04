declare
cursor c_location is
select max(PROTOCOL_LOCATION_ID) PROTOCOL_LOCATION_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,PROTOCOL_ORG_TYPE_CODE,ORGANIZATION_ID,ROLODEX_ID from PROTOCOL_LOCATION
group by PROTOCOL_NUMBER,SEQUENCE_NUMBER,PROTOCOL_ORG_TYPE_CODE,ORGANIZATION_ID,ROLODEX_ID
having count(PROTOCOL_LOCATION_ID)>1;
r_location c_location%rowtype;

begin
     if c_location%isopen then
	    close c_location;
	 end if;
	 open c_location;
	 loop
	 fetch c_location into r_location;
	 exit when c_location%notfound;
	  
	          delete from PROTOCOL_LOCATION
			  where PROTOCOL_LOCATION_ID <> r_location.PROTOCOL_LOCATION_ID
			  and PROTOCOL_NUMBER = r_location.PROTOCOL_NUMBER
			  and SEQUENCE_NUMBER = r_location.SEQUENCE_NUMBER
              and PROTOCOL_ORG_TYPE_CODE = r_location.PROTOCOL_ORG_TYPE_CODE
			  and ORGANIZATION_ID = r_location.ORGANIZATION_ID
			  and ROLODEX_ID = r_location.ROLODEX_ID;
			  
	 end loop;
	 close c_location;
end;
/
declare
cursor c_loc is
select p.PROTOCOL_ID,p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER from PROTOCOL p
left outer join PROTOCOL_LOCATION l on p.PROTOCOL_ID = l.PROTOCOL_ID
where l.PROTOCOL_ID is null
and p.SEQUENCE_NUMBER <> 0
order by p.PROTOCOL_ID,p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER;
r_loc c_loc%rowtype;

begin
     if c_loc%isopen then
	    close c_loc;
	 end if;
	 open c_loc;
	 loop
	 fetch c_loc into r_loc;
	 exit when c_loc%notfound;
	 
	      insert into PROTOCOL_LOCATION(PROTOCOL_LOCATION_ID,
                                        PROTOCOL_ID,
										PROTOCOL_NUMBER,
										SEQUENCE_NUMBER,
										PROTOCOL_ORG_TYPE_CODE,
										ORGANIZATION_ID,
										ROLODEX_ID,
										UPDATE_TIMESTAMP,
										UPDATE_USER,
										VER_NBR,
										OBJ_ID)
								 select SEQ_PROTOCOL_ID.NEXTVAL,
                                        r_loc.PROTOCOL_ID,
                                        r_loc.PROTOCOL_NUMBER,
                                        r_loc.SEQUENCE_NUMBER,	
                                        PROTOCOL_ORG_TYPE_CODE,
										ORGANIZATION_ID,
										ROLODEX_ID,
										UPDATE_TIMESTAMP,
										UPDATE_USER,
                                        1,
                                        sys_guid()
                                   from PROTOCOL_LOCATION 
								   where PROTOCOL_NUMBER = r_loc.PROTOCOL_NUMBER
                                   and SEQUENCE_NUMBER = ( select max(s.SEQUENCE_NUMBER) from PROTOCOL_LOCATION s 
                                   where s.PROTOCOL_NUMBER = r_loc.PROTOCOL_NUMBER 
                                   and s.SEQUENCE_NUMBER < r_loc.SEQUENCE_NUMBER);
						commit;		   
 
     end loop;
     close c_loc;
        	
           insert into PROTOCOL_LOCATION(PROTOCOL_LOCATION_ID,
                                         PROTOCOL_ID,
										 PROTOCOL_NUMBER,
										 SEQUENCE_NUMBER,
										 PROTOCOL_ORG_TYPE_CODE,
										 ORGANIZATION_ID,
										 ROLODEX_ID,
										 UPDATE_TIMESTAMP,
										 UPDATE_USER,
										 VER_NBR,
										 OBJ_ID)
                                  select SEQ_PROTOCOL_ID.NEXTVAL,
								         p.PROTOCOL_ID,
								         p.PROTOCOL_NUMBER,
										 p.SEQUENCE_NUMBER,
                                         1,
                                         '000001',
                                         1,
                                         sysdate,
                                         user,
                                         1,
                                         sys_guid()										 
								    from PROTOCOL p
                                    left outer join PROTOCOL_LOCATION l on p.PROTOCOL_NUMBER = l.PROTOCOL_NUMBER
                                    where l.PROTOCOL_NUMBER is null;
									
end;
/
commit
/
	   