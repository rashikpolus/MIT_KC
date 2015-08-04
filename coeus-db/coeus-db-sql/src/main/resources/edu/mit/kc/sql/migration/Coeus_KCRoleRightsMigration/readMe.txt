 Readme
-*-*-*-*-

To execute full script
-----------------------
connect to sqlplus by providing correct username/password@connection_name, then execute "all_role_rights.sql" file.
eg: @all_role_rights.sql.
Migration log can be viewed in logs directory with file name "error.log"


To Reload from temp role permission table 
-----------------------------------------
After making any change in role right mapping, It will truncate and repopulate role member and krim_role_perm_t table again.

connect to sqlplus by providing correct username/password@connection_name, then execute "reload_from_temp_role_perm.sql" file.
eg: @reload_from_temp_role_perm.sql.
Migration log can be viewed in logs directory with file name "errorFromReload.log"