create or replace
FUNCTION FN_UPDATE_LONG_SURVEY_OPT_OUT
	(AS_PI_ID IN LONG_SURVEY_OPT_OUT.PI_ID%TYPE)
return number IS
	li_rc	number;
  pi_count number;
  ret number; 
BEGIN
  
  select count(*) into pi_count from long_survey_opt_out where PI_ID = AS_PI_ID;
  
  if pi_count = 0 then
	insert into LONG_SURVEY_OPT_OUT (PI_ID, SURVEY_OPTOUT_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	values(AS_PI_ID ,SYSDATE,SYSDATE,USER,1,SYS_GUID());
  ret := 0;
  else
  ret := 1;
  end if;
  
	return ret;

END FN_UPDATE_LONG_SURVEY_OPT_OUT;

/