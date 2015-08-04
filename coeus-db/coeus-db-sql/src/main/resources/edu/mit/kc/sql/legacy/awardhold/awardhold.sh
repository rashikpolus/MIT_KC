echo `date` 'Starting awardhold.sh - Refresh award hold messages - Production'

cd /home/coeus/awardhold
rm -f /home/coeus/awardhold/awardhold.log


ORACLE_BASE=/oracle
export ORACLE_BASE

#ORACLE_HOME=$ORACLE_BASE/product/11.2.0.2/db
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db
export ORACLE_HOME

LD_LIBRARY_PATH=/usr/lib:/usr/shlib:$ORACLE_HOME/lib
export LD_LIBRARY_PATH

LIBHOME=$ORACLE_HOME/lib
export LIBHOME


ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`


$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @/home/coeus/awardhold/awardhold.sql

mail -s "Award Hold Messages Refresh - Production" coeus-test-email@mit.edu < /home/coeus/awardhold/awardhold.log

echo `date` 'End awardhold.sh'