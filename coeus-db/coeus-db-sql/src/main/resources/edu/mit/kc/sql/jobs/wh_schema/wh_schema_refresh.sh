echo `date` 'Starting Coeus WH Schema refresh ***Coeus Production Database***'
 
ORACLE_SID=OSPA
export ORACLE_SID
 
ORACLE_HOME=/oracle/product/11.2.0/db
export ORACLE_HOME
 
ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/home/coeus/wh/refresh_wh_schema.sql
 
 
#Create a txt file kc_done.txt with current date in it
#scp the file to WHPROD server to signal the completion of this process
# user coeus is configured to push files to DWPROD via scp without a password
# via SSH public key in coeus users home dir
#****************************************************************
 
echo `date` > kc_done.txt
scp kc_done.txt ospuser@dwprod:kc_done.txt
 
echo `date` 'End wh.sh'
 
mail -s 'WH Schema Refresh - Production Database - OSPA' coeus-dev-team@mit.edu < /home/coeus/wh/wh.log
