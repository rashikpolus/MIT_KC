update AWARD_REPORT_TERMS set OSP_DISTRIBUTION_CODE = null where OSP_DISTRIBUTION_CODE = -1
/
update AWARD_TEMPLATE_REPORT_TERMS set OSP_DISTRIBUTION_CODE = null where OSP_DISTRIBUTION_CODE = -1
/
delete from DISTRIBUTION where OSP_DISTRIBUTION_CODE = -1
/
commit
/
