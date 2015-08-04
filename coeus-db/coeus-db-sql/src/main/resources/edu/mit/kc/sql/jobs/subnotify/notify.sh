echo `date` 'Starting SUB Notifications ** Production'

cd /home/coeus/subnotify

ORACLE_BASE=/oracle
export ORACLE_BASE

ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db
export ORACLE_HOME


LIBHOME=$ORACLE_HOME/lib
export LIBHOME

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`

$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @/home/coeus/subnotify/notify.sql
#mail -s "Sub Notification log - Production" coeus-dev-team@mit.edu < /home/coeus/subnotify/notify.log
echo `date` 'End Sub Notify'
