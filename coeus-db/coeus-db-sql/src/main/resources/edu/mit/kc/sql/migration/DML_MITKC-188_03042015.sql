update EVERIFY_NOTIF_DETAILS
set AWARD_NUMBER = replace(AWARD_NUMBER,'-','-00')
where length(AWARD_NUMBER) = 10
/
update SAP_FEED_DETAILS
set AWARD_NUMBER = replace(AWARD_NUMBER,'-','-00')
where length(AWARD_NUMBER) = 10
/
update EVERIFY_NOTIF_DETAILS t1 set t1.AWARD_NUMBER = (select distinct s1.change_award_number 
from kc_mig_award_conv s1 where s1.award_number = t1.AWARD_NUMBER)
where t1.AWARD_NUMBER in (select s2.award_number from kc_mig_award_conv s2)
/
update SAP_FEED_DETAILS t1 set t1.AWARD_NUMBER = (select distinct s1.change_award_number 
from kc_mig_award_conv s1 where s1.award_number = t1.AWARD_NUMBER)
where t1.AWARD_NUMBER in (select s2.award_number from kc_mig_award_conv s2)
/
commit
/