-- If you have already ran the below update statement then please don't run this again 
UPDATE sap_feed_details SET award_number = replace(award_number,'-','-00') where length(award_number) <=10 
/
commit
/
-- This will update the AAA types of award number to KC numbers
UPDATE sap_feed_details t1
SET t1.award_number = ( select t2.change_award_number from kc_mig_award_conv t2 where t1.award_number = t2.award_number)
WHERE EXISTS ( select t2.change_award_number from kc_mig_award_conv t2 where t1.award_number = t2.award_number)
/
commit
/
