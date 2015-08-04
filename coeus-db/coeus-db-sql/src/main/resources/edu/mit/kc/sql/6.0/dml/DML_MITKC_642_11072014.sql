update KRCR_PARM_T set VAL = 'Y' where PARM_NM= 'iacuc.protocol.institute.proposal.linking.enabled';
/
update KRCR_PARM_T set VAL = 'Y' where PARM_NM= 'irb.protocol.institute.proposal.linking.enabled';

update KRCR_PARM_T set VAL = 'Y' where PARM_NM= 'iacuc.protocol.award.linking.enabled';
/
update KRCR_PARM_T set VAL = 'Y' where PARM_NM= 'irb.protocol.award.linking.enabled';
/
update KRCR_PARM_T set VAL = 'Y' where PARM_NM= 'iacuc.protocol.proposal.development.linking.enabled';
/
update KRCR_PARM_T set VAL = 'Y' where PARM_NM= 'irb.protocol.development.proposal.linking.enabled';
/  
commit
/