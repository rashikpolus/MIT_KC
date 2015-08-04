echo `date` 'Starting Roles DB refresh for EDS ***Coeus PROD Instance***'

ORACLE_SID=OSPA
export ORACLE_SID

ORACLE_HOME=/oracle/product/11.2.0/db
export ORACLE_HOME

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/home/coeus/eds/roles_refresh.sql


echo `date` 'End roles_refresh.sh'

mail -s 'EDS Roles refresh  - PROD Instance - OSPA' coeus-dev-team@mit.edu < /home/coeus/eds/roles_refresh.log
