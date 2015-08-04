UPDATE PROTO_AMEND_RENEW_MODULES SET  protocol_module_code = '024' WHERE protocol_module_code = '005'
/
UPDATE PROTO_AMEND_RENEW_MODULES SET  protocol_module_code = '002' WHERE protocol_module_code = '003'
/
commit
/
DELETE FROM protocol_modules WHERE protocol_module_code = '005'
/
commit
/
