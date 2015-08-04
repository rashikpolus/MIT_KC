echo `date` 'Starting Roles DB refresh for OPA ***Coeus Prod Instance***'


ORACLE_SID=OSPA
export ORACLE_SID

ORACLE_HOME=/oracle/product/11.2.0/db
export ORACLE_HOME

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/home/coeus/opa/roles_refresh.sql


echo `date` 'End roles_refresh.sh'

mail -s 'Roles Refresh -HOURLY- Production Database - OSPA' coeus-dev-team@mit.edu < /home/coeus/opa/roles_refresh.log