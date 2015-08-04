UPDATE notification_type set send_notification = 'N' WHERE action_code in (552,553) and module_code = 2
/
UPDATE notification_type set send_notification = 'N' WHERE action_code  in (552,553) and module_code = 1
/
UPDATE notification_type set SEND_NOTIFICATION = 'N' WHERE action_code  in (554,555) and module_code = 1
/
commit
/