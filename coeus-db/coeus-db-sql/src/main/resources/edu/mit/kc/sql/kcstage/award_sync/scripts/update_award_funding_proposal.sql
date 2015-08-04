select ' Started UPDATE_AWARD_FUNDING_PROPOSALS ' from dual
/
DECLARE
li_count number(12,0);
ls_award_number VARCHAR2(20);

CURSOR c_funding IS
SELECT MIT_AWARD_NUMBER ,SEQUENCE_NUMBER from TEMP_TAB_TO_SYNC_AWARD  WHERE FEED_TYPE = 'C';


r_funding c_funding%ROWTYPE;

BEGIN
IF c_funding%ISOPEN  THEN
CLOSE c_funding;
END IF;
OPEN c_funding;
LOOP
FETCH c_funding INTO r_funding;
EXIT WHEN c_funding%NOTFOUND;

	select count(*) into li_count from KC_MIG_AWARD_CONV where AWARD_NUMBER = replace(r_funding.MIT_AWARD_NUMBER,'-','-00');

	IF li_count = 1 THEN
		select CHANGE_AWARD_NUMBER into ls_award_number FROM KC_MIG_AWARD_CONV WHERE AWARD_NUMBER = replace(r_funding.MIT_AWARD_NUMBER,'-','-00');
		
	ELSE
		ls_award_number := replace(r_funding.MIT_AWARD_NUMBER,'-','-00');

	END IF;


	select count(*) into li_count from
	(
		select AWARD_ID,PROPOSAL_ID 
		from AWARD_FUNDING_PROPOSALS
		where  AWARD_ID = (select s1.AWARD_ID from award s1 where s1.AWARD_NUMBER = ls_award_number and s1.SEQUENCE_NUMBER = r_funding.SEQUENCE_NUMBER)

		minus

		select t.award_id, p.proposal_id
		from  award t,proposal p,OSP$AWARD_FUNDING_PROPOSALS af,TEMP_TAB_TO_SYNC_AWARD ts
		where t.award_number = replace(af.MIT_AWARD_NUMBER,'-','-00')
		and   t.SEQUENCE_NUMBER = af.SEQUENCE_NUMBER
		and  af.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER
		and  af.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER
		and p.proposal_number = af.proposal_number
		and p.sequence_number = af.PROP_SEQUENCE_NUMBER
		and ts.MIT_AWARD_NUMBER = r_funding.MIT_AWARD_NUMBER
		and ts.SEQUENCE_NUMBER  = r_funding.SEQUENCE_NUMBER
	);


	IF li_count > 0 THEN

		DELETE FROM AWARD_FUNDING_PROPOSALS t1
		WHERE t1.AWARD_ID = ( select s1.AWARD_ID from award s1 where s1.AWARD_NUMBER = ls_award_number and s1.SEQUENCE_NUMBER = r_funding.SEQUENCE_NUMBER);

		commit;

		INSERT INTO AWARD_FUNDING_PROPOSALS(AWARD_FUNDING_PROPOSAL_ID,AWARD_ID,PROPOSAL_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTIVE,OBJ_ID)
		select SEQUENCE_AWARD_ID.NEXTVAL,t.award_id, p.proposal_id,af.UPDATE_TIMESTAMP,af.UPDATE_USER,1,'Y',SYS_GUID()
		from  award t,proposal p,OSP$AWARD_FUNDING_PROPOSALS af,TEMP_TAB_TO_SYNC_AWARD ts
		where t.award_number = replace(af.MIT_AWARD_NUMBER,'-','-00')
		and   t.SEQUENCE_NUMBER = af.SEQUENCE_NUMBER
		and  af.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER
		and  af.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER
		and  p.proposal_number = af.proposal_number
		and p.sequence_number = af.PROP_SEQUENCE_NUMBER
		and ts.MIT_AWARD_NUMBER = r_funding.MIT_AWARD_NUMBER
		and ts.SEQUENCE_NUMBER  = r_funding.SEQUENCE_NUMBER;
		
		commit;

	END IF;


END LOOP;
CLOSE c_funding;
END;
/
select ' Ended UPDATE_AWARD_FUNDING_PROPOSALS ' from dual
/