 
Coeus-Kuali AWARD_SYNC DATA MIGRATION
===================================

The migration bundle helps to sync award data in  Coeus and kuali database.

Step for Migration
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Step 1: 
------
Please reach the correct path of the Sync directory and connect to SQLPLUS by providing correct username/password@connection_name. Given below is an example
	sqlplus username/pwd@connectionName
Step 2: 
------
On successful establishment of connection, sqlplus prompt will be displayed. Please type “@start_sync.sql “in the prompt to start the migration.

Step 3:
------
The log "sync_error.log" can be found inside logs folder.



After completion of syncing,  application will send notifications to the recipients with the message saying which all projects are updated by this sync. By default the recipients are set as 'kc-mit-dev@mit.edu'.If you want to change the recipients then goto the sql file "send_notification.sql" in the main directory and change the value of the variable "ls_receipt".



Validation
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Step 1: 
------
Please reach the correct path of the Sync directory and connect to SQLPLUS by providing correct username/password@connection_name. Given below is an example
	sqlplus username/pwd@connectionName
Step 2: 
------
On successful establishment of connection, sqlplus prompt will be displayed. Please type “@start_validation.sql “in the prompt to start the validaiton.

Step 3:
------
The log "validation_error.log" can be found inside logs folder.
