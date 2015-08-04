echo `date` 'Starting COI Notifications ** COI  PROD'

cd /home/coeus/coi

ORACLE_BASE=/oracle
export ORACLE_BASE

ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db
export ORACLE_HOME

LIBHOME=$ORACLE_HOME/lib
export LIBHOME

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`

$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @/home/coeus/coi/notify.sql
mail -s "COI Notifications - Production" coeus-dev-team@mit.edu < /home/coeus/coi/notify_coi.log
echo `date` 'End COI Notification.sh'