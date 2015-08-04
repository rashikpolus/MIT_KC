echo `date` 'Starting WorkLoad Aggregator Load.sh ***Coeus Production Database***'

ORACLE_SID=OSPA
export ORACLE_SID

ORACLE_HOME=/oracle/product/11.2.0/db
export ORACLE_HOME

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/home/coeus/wl/refresh_wl_aggregator_tables.sql


echo `date` 'End wl.sh'

mail -s 'WL Aggregator Load - Production Database - OSPA' coeus-dev-team@mit.edu < /home/coeus/wl/wl.log

