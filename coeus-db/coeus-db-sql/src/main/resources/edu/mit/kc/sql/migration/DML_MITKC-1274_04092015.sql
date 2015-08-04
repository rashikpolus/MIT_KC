delete from kcso.award_funding_proposals
where award_id in (select award_id from kcso.award where award_number in  
                                                          (select replace(af.MIT_AWARD_NUMBER,'-','-00') from OSP$AWARD_FUNDING_PROPOSALS@coeus.kuali af )
              )
/
commit
/
INSERT INTO AWARD_FUNDING_PROPOSALS(AWARD_FUNDING_PROPOSAL_ID,AWARD_ID,PROPOSAL_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTIVE,OBJ_ID)
select SEQUENCE_AWARD_ID.NEXTVAL,t.award_id, p.proposal_id,af.UPDATE_TIMESTAMP,af.UPDATE_USER,1,'Y',SYS_GUID()
from  award t,proposal p,OSP$AWARD_FUNDING_PROPOSALS@coeus.kuali af
where t.award_number = replace(af.MIT_AWARD_NUMBER,'-','-00')
and   t.SEQUENCE_NUMBER = af.SEQUENCE_NUMBER
and p.proposal_number = af.proposal_number
and p.sequence_number = (select max(s1.sequence_number) from proposal s1 where s1.proposal_number = af.proposal_number)
/
commit
/
